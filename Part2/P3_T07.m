%% Requirement 1
clc; clearvars; close all;

Ts = 1; %symbol duration
nspd = 5; %number of samples per duration
t = 0: Ts/nspd : (nspd-1)/nspd * Ts; %time axis

no_of_binary_samples = 10;
x = randi([0 1], 1, no_of_binary_samples);
bps = 2*x-1; %binary polar signal
bps = upsample(bps, nspd);

p = -5/Ts * t + 5; %pulse shaping function
p_normalized = normalize_power(p); %Renamed to avoid built-in conflict

y = conv(bps, p_normalized);

h_matched = fliplr(p_normalized); %Matched Filter
y_filtered1 = conv(y, h_matched);
y_filtered1_resampled = downsample(y_filtered1, nspd, nspd-1);


h2 = ones(1, nspd);
h2_normalized = normalize_power(h2);
y_filtered2 = conv(y, h2_normalized);
y_filtered2_resampled = downsample(y_filtered2, nspd, nspd-1);

%time axis for plotting
t_axis_new = 0: Ts/nspd: (nspd*no_of_binary_samples + 2*nspd -3) *(Ts/nspd);
t_axis_downsampled = downsample(t_axis_new, nspd, nspd-1);

figure('Name', 'Requirement1a', 'Color', [1 1 1]);

subplot(2, 1, 1);
plot(t_axis_new, y_filtered1, 'b', 'LineWidth', 1.2);
title('Y[n] Filtered by Matched Filter', 'FontSize', 11);
xlabel('t (sec)');
ylabel('Y[n]');
grid on;

hold on;
stem(t_axis_downsampled, y_filtered1_resampled, 'k', 'LineWidth', 1.2); 
title('Y[n] Downsampled (Matched)', 'FontSize', 11);
xlabel('t (sec)');
ylabel('Y[n]');
grid on;

subplot(2, 1, 2);
plot(t_axis_new, y_filtered2, 'r', 'LineWidth', 1.2);
title('Y[n] Filtered by Second Filter', 'FontSize', 11);
xlabel('t (sec)');
ylabel('Y[n]');
grid on;

hold on;
stem(t_axis_downsampled, y_filtered2_resampled, 'k', 'LineWidth', 1.2); 
title('Y[n] Downsampled (Second)', 'FontSize', 11);
xlabel('t (sec)');
ylabel('Y[n]');
grid on;

%Correlator
corr_out = zeros(1, nspd*no_of_binary_samples + 2*nspd -2);
for i=1: no_of_binary_samples
    acc_mem = 0; %accumulator memory
    for j = 1: nspd
        corr_out((i-1)*nspd + j) = acc_mem + y((i-1) * nspd + j) * p_normalized(j);
        acc_mem = corr_out((i-1)*nspd + j);
    end
end

corr_out_resampled = downsample(corr_out, nspd, nspd-1);

figure('Name', 'Requirement1b', 'Color', [1 1 1]);
subplot(3, 1, 1); 
plot(t_axis_new, y_filtered1, 'b', 'LineWidth', 1.2);
hold on;
plot(t_axis_new, corr_out, 'r', 'LineWidth', 1.2);
title('Y[n] Filtered by both matched and correlator', 'FontSize', 11);
xlabel('t (sec)');
ylabel('Y[n]');
legend('Matched Filter', 'Correlator');
grid on;
subplot(3, 1, 2);
plot(t_axis_new, y_filtered1, 'b', 'LineWidth', 1.2, 'LineStyle', '--'); 
hold on;
stem(t_axis_downsampled, y_filtered1_resampled, 'k', 'LineWidth', 1.2); 
title('Y[n] Downsampled (First)', 'FontSize', 11);
xlabel('t (sec)');
ylabel('Y[n]');
legend('Continuous', 'Sampled');
grid on;
subplot(3, 1, 3);
plot(t_axis_new, corr_out, 'r', 'LineWidth', 1.2, 'LineStyle', '--'); 
hold on;
stem(t_axis_downsampled, corr_out_resampled, 'g', 'LineWidth', 1.2); 
title('Correlator Output Downsampled', 'FontSize', 11); 
xlabel('t (sec)');
ylabel('Y[n]');
legend('Continuous', 'Sampled');
grid on;

%% Requirement 2
no_of_binary_samples = 10000;
x = randi([0 1], 1, no_of_binary_samples);
bps = 2*x-1; %binary polar signal
bps = upsample (bps, nspd);
y = conv (bps, p_normalized);

BER_theoritical = zeros (1, 8);
BER_practical_matched_filter = zeros (1, 8);
BER_practical_filter2 = zeros (1,8);
for db_sweep = -2: 1: 5

    N0_db = 0 - db_sweep;
    N0_linear = 10 ^ (N0_db/10);
    
    BER_theoritical(db_sweep + 3) = 0.5 *erfc(sqrt(1/N0_linear));
    noise = sqrt (N0_linear/2) .* randn (size (y));
    v = y + noise;
    y_filtered1 = conv (v, h_matched);
    y_filtered1_resampled = downsample (y_filtered1, nspd, nspd-1);
    t_axis_new = 0: Ts/nspd: (nspd*no_of_binary_samples + 2*nspd -3) *(Ts/nspd);

    %BER:
    BER_practical_matched_filter(db_sweep + 3) = bit_error_rate ...
                                 (x, y_filtered1_resampled);
    h2 = 5 * ones(1, nspd);
    y_filtered2 = conv(v, h2);
    y_filtered2_resampled = downsample(y_filtered2, nspd, nspd-1);
    BER_practical_filter2(db_sweep + 3) = bit_error_rate ...
                                 (x, y_filtered2_resampled);
end

x_axis_of_BER = -2:1:5;
figure('Name', 'Requirement2', 'Color', [1 1 1]);
plot (x_axis_of_BER, BER_theoritical, 'b', 'LineWidth', 1.2);
hold on;
plot (x_axis_of_BER, BER_practical_matched_filter, 'r', 'LineWidth', 1.2);
hold on;
plot (x_axis_of_BER, BER_practical_filter2, 'g', 'LineWidth', 1.2);
title('Requirement2', 'FontSize', 11);
xlabel ('Eb/N0 (db)');
ylabel('BER');
legend ('Theoritical BER', 'Practical BER of Matched Filter', ...
                            'Practical BER of Second Filter');
grid on;

%% Requirement 3
no_of_binary_samples = 100;
nspd = 100;

x = randi([0 1], 1, no_of_binary_samples);
bps = 2*x - 1;
bps = upsample(bps, nspd);

rolloff_factor = [0, 1];
delay = [2, 8];

for i = 1:length(rolloff_factor)
    for j = 1:length(delay)

        % Filter
        span = delay(j);
        filter = rcosdesign(rolloff_factor(i), span, nspd, 'sqrt');

        filt_delay = (span * nspd) / 2;

        % Tx
        Tx = conv(bps, filter);
        Tx = Tx(filt_delay+1:end-filt_delay);

        % Rx
        Rx = conv(Tx, filter);
        Rx = Rx(filt_delay+1:end-filt_delay);

        % Fix length
        Tx = Tx(1 : floor(length(Tx)/nspd)*nspd);
        Rx = Rx(1 : floor(length(Rx)/nspd)*nspd);


        % Tx Eye 
        eyediagram(Tx, 2*nspd);
        title(sprintf('Tx Eye | R=%g, Delay=%g', ...
              rolloff_factor(i), delay(j)));

        % Rx Eye 
        eyediagram(Rx, 2*nspd);
        title(sprintf('Rx Eye | R=%g, Delay=%g', ...
              rolloff_factor(i), delay(j)));

    end
end
%% Functions
function [array_normalized] = normalize_power(array)
    array_power = 0;
    for i = 1: length(array)
        array_power = array_power + abs(array(i))^2;
    end
    array_normalized = array / sqrt(array_power);
end

function [BER] = bit_error_rate (original, received)
no_of_bits = length (original);
    error_bits_count = 0;
    for i = 1: no_of_bits
        if received(i) >= 0
            received_binary = 1;
        else
            received_binary = 0;
        end
        if received_binary  ~= original(i)
            error_bits_count = error_bits_count +1;
        end
    end
BER = error_bits_count / no_of_bits;

end