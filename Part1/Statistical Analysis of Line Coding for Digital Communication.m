clear; clc; close all;

%% Parameters
A = 4;
num_bits = 100;
num_waveforms = 500;
samples_per_bit = 7;
Ts = 1 / 100;

% ===== Control Variable =====
% 1 = Unipolar
% 2 = Polar NRZ
% 3 = RZ

for line_code = 1:3; % Its end is at the last line of the code
if line_code == 1
    fprintf('==========Unipolar Requirments==========\n');
elseif line_code == 2
    fprintf('==========Polar NRZ Requirments==========\n');
elseif line_code == 3
    fprintf('==========RZ Requirments==========\n'); 
end
%% Generating Ensemble
ensemble = zeros(num_waveforms, num_bits * samples_per_bit);

for i = 1:num_waveforms
    
    % Random bits
    Data = randi([0 1], 1, num_bits);
    
    % ===== LINE CODING SELECTION =====
    %-----------
    if line_code == 1
        % Unipolar (0 → 0, 1 → A)
        Tx = Data * A;
        Tx2 = repmat(Tx, samples_per_bit, 1);
        Tx_out = reshape(Tx2, 1, []);
        
    elseif line_code == 2
        % Polar NRZ (0 → -A, 1 → +A)
        Tx = ((2 * Data) - 1) * A;
        Tx2 = repmat(Tx, samples_per_bit, 1);
        Tx_out = reshape(Tx2, 1, []);

    elseif line_code == 3
        % RZ (Return to Zero)
        Tx = ((2 * Data) - 1) * A;
        Tx_out = zeros(1, num_bits * samples_per_bit);
        
        for k = 1:num_bits
            start_idx = (k-1)*samples_per_bit + 1;
            Tx_out(start_idx:start_idx+3) = Tx(k); % first half
            Tx_out(start_idx+4:start_idx+6) = 0;   % second half
        end

    end
    
    ensemble(i, :) = Tx_out;
    %-----------
end

% LABEL
%-----------
if line_code == 1
    code_name = 'Unipolar';
elseif line_code == 2
    code_name = 'Polar NRZ';
else
    code_name = 'RZ';
end
%-----------
%% ================================
% 1) Statistical Mean
% ================================
%-----------
[num_rows, num_cols] = size(ensemble);
mean_signal = zeros(1, num_cols);

for j = 1:num_cols
    sum_val = 0;
    for i = 1:num_rows
        sum_val = sum_val + ensemble(i,j);
    end
    mean_signal(j) = sum_val / num_rows;
end
%-----------

% variance of mean ( Integrations means Summation )
%-----------
mean_of_mean = 0;
for j = 1:num_cols
    mean_of_mean = mean_of_mean + mean_signal(j);
end
mean_of_mean = mean_of_mean / num_cols;
%-----------

% Geting The VAR using the simple equation Var(x) = E[(x - μ)^2]
%-----------
var_sum = 0;
for j = 1:num_cols
    var_sum = var_sum + (mean_signal(j) - mean_of_mean) ^2;
end
mean_variation = var_sum / num_cols;
%-----------

% Ploting Mean and Variance
%-----------
fprintf('Mean of Mean = %f\n', mean_of_mean);
fprintf('Variance of mean over time = %f\n', mean_variation);
figure;
plot(mean_signal);
title(['Statistical Mean - ' code_name]);
xlabel('Time');
ylabel('Mean');
%-----------

%% ================================
% 2) Stationary Check
% ================================
if mean_variation < 0.01 * mean_of_mean % To compare it with the Mean of Mean
    disp('Process is approximately Stationary');
else
    disp('Process is NOT Stationary');
end

%% ================================
% 3) ENSEMBLE AUTOCORRELATION
% ================================

lags = -(num_cols-1):(num_cols-1);
Rx = zeros(1, length(lags));

for i = 1:num_waveforms
    x = ensemble(i,:);  % one waveform
    
    for tau = -(num_cols-1):(num_cols-1)
        sum_val = 0;
        
        for n = 1:num_cols
            if (n+tau >= 1) && (n+tau <= num_cols)
                sum_val = sum_val + x(n) * x(n+tau);
            end
        end
        Rx(tau + num_cols) = Rx(tau + num_cols) + (sum_val / num_cols);
    end
end

% average over all waveforms
Rx = Rx / num_waveforms;

% plot
figure;
plot(lags, Rx);
title(['Autocorrelation - ' code_name]);
xlabel('Lag');
ylabel('R_x');
%% ================================
% 4) Time Mean & Autocorrelation functions
% ================================
one_wave = ensemble(1,:);

% time mean
%-----------
sum_val = 0;
for i = 1:num_cols
    sum_val = sum_val + one_wave(i);
end
time_mean = sum_val / num_cols;
fprintf('Time mean (one waveform) = %f\n', time_mean);
%-----------

% autocorrelation (manual)
%-----------
r1 = zeros(1, length(lags));

for tau = -(num_cols-1):(num_cols-1)
    sum_val = 0;
    
    for n = 1:num_cols
        n_shift = n + tau;
        
        if (n_shift >= 1) && (n_shift <= num_cols)
            sum_val = sum_val + one_wave(n) * one_wave(n_shift);
        end
    end
    
    r1(tau + num_cols) = sum_val / num_cols;
end
%-----------

%Ploting
%-----------
figure;
plot(lags, r1);
title(['Autocorrelation (Single) - ' code_name]);
xlabel('Lag');
ylabel('R_x');
%-----------

%% ================================
% 5) Ergodicity Check
% ================================

% ensemble mean
%-----------
sum_val = 0;
for j = 1:num_cols
    sum_val = sum_val + mean_signal(j);
end
ensemble_mean_total = sum_val / num_cols;
%-----------
fprintf('Ensemble Mean = %f\n', ensemble_mean_total);

% Estimating Error between Time and ensemle means
%-----------
relative_error = abs(time_mean - ensemble_mean_total) / abs(ensemble_mean_total);
fprintf('Relative Error = %f\n', relative_error);

if relative_error < 1e-2
    disp('Process is approximately Ergodic');
else
    disp('Process is NOT Ergodic');
end
%-----------

%% ================================
% 6) Bandwidth Estimation
% ================================
fs = 1 / Ts;
signal = ensemble(1,:);

Nfft = length(signal);
f = (-Nfft/2:Nfft/2-1)*(fs/Nfft);

S = fftshift(abs(fft(signal)));

figure;
plot(f, S);
title(['Frequency Spectrum - ' code_name]);
xlabel('Frequency (Hz)');
ylabel('Magnitude');

threshold = max(S)*0.1;
indices = find(S > threshold);

bandwidth = f(max(indices)) - f(min(indices));

fprintf('Estimated Bandwidth ≈ %f Hz\n', bandwidth);


fprintf('==========End of the requriments==========\n'); 
end