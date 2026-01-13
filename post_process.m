%% ========================================================================
%          ST4Health Masters DMH - Research Project - Signal Processing
%                    A. Obert, A. Heddadj, C. Moy
%
%   This script:
%   - Illustrates the processing pipeline on one subject
%   - Applies the same pipeline to all subjects to average results
%% ========================================================================

clear; clc; close all

% GENERAL CONFIGURATION
fs = 1000;                 % Sampling frequency (Hz)
fs_hrv = 4;                % Interpolation frequency for HRV (Hz)

poseDuration = 5 * 60;     % Duration of each posture (s)
poses = {'Resting','Tadasana','Adhomukhasana', ...
         'Paschimottanasana','Virabhadrasana','Shavasana'};
Nposes = numel(poses);

%% ========================================================================
%                   1 — SINGLE SUBJECT PROCESSING
%% ========================================================================

% Signal trimming (to remove unstable segments)
sec_a_retirer_debut = 60;  % seconds removed at beginning
sec_a_retirer_fin   = 45;  % seconds removed at end

% !! LOADING DATA !!
file = '/MATLAB Drive/raw/opensignals_98d351fe6f0f_2026-01-05_19-34-03.txt'; % Modify path if needed
opts = detectImportOptions(file);
opts.CommentStyle = '#';
data = readmatrix(file, opts);

% Removing initial and final segments 
data = data(sec_a_retirer_debut*fs+1 : end-sec_a_retirer_fin*fs, :);

t = (0:size(data,1)-1)/fs;   % Time vector

ECG = data(:,7);             % ECG channel
PZT = data(:,6);             % Respiration channel (PZT)

% ECG PREPROCESSING
% Removing DC component and invert signal
ecg_filt = ECG - mean(ECG);
ecg_filt = -ecg_filt;

% Low-pass Butterworth filter (2nd order, 30 Hz cutoff)
[b,a] = butter(2, 30/(fs/2), 'low');
ecg_filt = filtfilt(b,a,ecg_filt);

% R-PEAK DETECTION
% Peaks correspond to heartbeats
minPeakDist   = round(0.4*fs);                  % Minimum RR = 400 ms
minPeakHeight = median(ecg_filt) + 0.5*std(ecg_filt);

[pks, locs] = findpeaks(ecg_filt, ...
    'MinPeakDistance', minPeakDist, ...
    'MinPeakHeight', minPeakHeight);

% RR intervals
RR      = diff(locs)/fs;        % RR intervals (s)
RR_time = locs(2:end)/fs;       % Time of RR intervals (s)

% TIME-DOMAIN VISUALIZATION
% Raw Signals
figure;
subplot(2,1,1)
plot(t, ECG)
title('Raw ECG')
xlabel('Time (s)'); ylabel('Amplitude')
grid on

subplot(2,1,2)
plot(t, PZT)
title('Raw Respiration (PZT)')
xlabel('Time (s)'); ylabel('Amplitude')
grid on

% ECG WITH DETECTED R-PEAKS
figure;
plot(t, ecg_filt); hold on
plot(locs/fs, pks, 'ro')
xlabel('Time (s)'); ylabel('ECG (filtered)')
title('R-peak Detection')
grid on
xlim([0 10])

% RR INTERVALS
figure;
plot(RR_time, RR*1000)
xlabel('Time (s)')
ylabel('RR interval (ms)')
title('R-R Tachogram')
grid on

% FREQUENCY DOMAIN HRV ANALYSIS (WELCH)
% HRV frequency bands
LF_band = [0.04 0.15];   % Low Frequency
HF_band = [0.15 0.40];   % High Frequency

LF_all = zeros(1,Nposes);
HF_all = zeros(1,Nposes);

figure('Position',[100 100 1400 800])

for k = 1:Nposes

    % Extracting ECG segment corresponding to posture
    idx_start = round((k-1)*poseDuration*fs)+1;
    idx_end   = min(round(k*poseDuration*fs), length(ecg_filt));
    seg = ecg_filt(idx_start:idx_end);

    % R-peak detection within the segment
    [~, locs_seg] = findpeaks(seg, ...
        'MinPeakDistance', minPeakDist, ...
        'MinPeakHeight', median(seg)+0.5*std(seg));

    % RR intervals for the posture
    RR_seg      = diff(locs_seg)/fs;
    RR_time_seg = locs_seg(2:end)/fs;

    % Interpolation to evenly sampled signal
    t_interp = RR_time_seg(1):1/fs_hrv:RR_time_seg(end);
    RR_interp = interp1(RR_time_seg, RR_seg, t_interp, 'spline');

    % Power Spectral Density using Welch method
    [pxx,f] = pwelch(RR_interp, [], [], [], fs_hrv);

    % Integrating power in LF and HF bands
    LF_all(k) = trapz(f(f>=LF_band(1)&f<=LF_band(2)), ...
                      pxx(f>=LF_band(1)&f<=LF_band(2)));
    HF_all(k) = trapz(f(f>=HF_band(1)&f<=HF_band(2)), ...
                      pxx(f>=HF_band(1)&f<=HF_band(2)));

    % Plot PSD
    subplot(2,3,k)
    plot(f,pxx,'LineWidth',1.5)
    xlim([0 0.5])
    xlabel('Frequency (Hz)')
    ylabel('PSD (s^2)')
    title([poses{k}, ' – HRV PSD'])
    grid on
end

sgtitle('HRV Power Spectrum per Pose (Welch)')

% LF/HF NORMALIZED UNITS TO MATCH ARTICLE
% Note: Normalized units express relative sympathetic / parasympathetic balance
LF_nu = LF_all ./ (LF_all + HF_all) * 100;
HF_nu = HF_all ./ (LF_all + HF_all) * 100;

figure;
bar([LF_nu; HF_nu]','grouped')
xticks(1:Nposes)
xticklabels(poses)
ylabel('Power (nu)')
legend({'LF','HF'})
title('LF/HF Power per Pose (Normalized Units)')
grid on
ylim([0 100])

%% ========================================================================
%                   PART 2 — MULTI-SUBJECT AVERAGING
%% ========================================================================

dataFolder = 'raw';   % folder containing .txt files, change path if needed
files = dir(fullfile(dataFolder, '*.txt'));
Nsubjects = length(files);

poses = {'Resting','Tadasana','Adhomukhasana','Paschimottanasana','Virabhadrasana','Shavasana'};
Nposes = numel(poses);
poseDuration = 5*60;

fs = 1000;
fs_hrv = 4;

LF_band = [0.04 0.15];
HF_band = [0.15 0.4];

LF_all = nan(Nsubjects, Nposes);
HF_all = nan(Nsubjects, Nposes);

for s = 1:Nsubjects
    fprintf('Processing %s\n', files(s).name)

    file = fullfile(dataFolder, files(s).name);
    opts = detectImportOptions(file);
    opts.CommentStyle = '#';
    data = readmatrix(file, opts);

    ECG = data(:,7);

    % ECG preprocessing
    ecg_filt = ECG - mean(ECG);
    ecg_filt = -ecg_filt;

    [b,a] = butter(2, 30/(fs/2), 'low');
    ecg_filt = filtfilt(b,a,ecg_filt);

    % R-peak detection (global)
    minPeakDist = round(0.4*fs);
    minPeakHeight = median(ecg_filt) + 0.5*std(ecg_filt);
    [~, locs] = findpeaks(ecg_filt, ...
        'MinPeakDistance', minPeakDist, ...
        'MinPeakHeight', minPeakHeight);

    % Pose-wise HRV
    for k = 1:Nposes
        start_idx = round((k-1)*poseDuration*fs)+1;
        end_idx   = min(round(k*poseDuration*fs), length(ecg_filt));

        if end_idx <= start_idx
            continue
        end

        seg_locs = locs(locs >= start_idx & locs <= end_idx) - start_idx;
        if numel(seg_locs) < 10
            continue
        end

        RR = diff(seg_locs)/fs;
        RR_time = seg_locs(2:end)/fs;

        if length(RR) < 10
            continue
        end

        % Interpolation
        t_interp = RR_time(1):1/fs_hrv:RR_time(end);
        RR_interp = interp1(RR_time, RR, t_interp, 'spline');

        % Welch PSD
        [pxx,f] = pwelch(RR_interp, [], [], [], fs_hrv);

        LF_all(s,k) = trapz(f(f>=LF_band(1) & f<=LF_band(2)), ...
                            pxx(f>=LF_band(1) & f<=LF_band(2)));

        HF_all(s,k) = trapz(f(f>=HF_band(1) & f<=HF_band(2)), ...
                            pxx(f>=HF_band(1) & f<=HF_band(2)));
    end
end

LF_mean = nanmean(LF_all,1);
HF_mean = nanmean(HF_all,1);

LF_nu = LF_mean ./ (LF_mean + HF_mean) * 100;
HF_nu = HF_mean ./ (LF_mean + HF_mean) * 100;

figure;
bar([LF_nu; HF_nu]','grouped')
xticks(1:Nposes)
xticklabels(poses)
ylabel('Power (nu)')
legend({'LF','HF'}, 'Location','northwest')
title('Average LF/HF per Pose (All Subjects)')
grid on
ylim([0 100])


