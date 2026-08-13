clear;
clc;
close all;

%% =========================================================
% LOAD LSL
% ==========================================================

disp("Loading LSL...");

lib = lsl_loadlib();

%% =========================================================
% FIND EEG STREAM
% ==========================================================

disp("Searching for BrainBit LSL stream...");

result = {};

while isempty(result)

    result = lsl_resolve_byprop(lib,'type','EEG');

    pause(1);

end

disp("EEG Stream Found!");

%% =========================================================
% CREATE LSL INLET
% ==========================================================

inlet = lsl_inlet(result{1});

disp("Receiving EEG chunks...");


%% =========================================================
% SETTINGS
% ==========================================================

fs = 250;

numChannels = 4;

windowSeconds = 10;

maxSamples = fs * windowSeconds;

% Vertical distance between channels
verticalSpacing = 1;

% Signal amplification on screen
gain = 5;

%% =========================================================
% ROLLING EEG BUFFER
% ==========================================================

EEG = zeros(0,numChannels);

Time = zeros(0,1);

chunkNumber = 0;

%% =========================================================
% CREATE FIGURE
% ==========================================================

fig = figure( ...
    'Name','BrainBit Live EEG', ...
    'NumberTitle','off', ...
    'Color','w');

ax = axes('Parent',fig);

hold(ax,'on');

grid(ax,'on');

%% =========================================================
% CREATE FOUR EEG LINES
% ==========================================================

line1 = plot(ax,nan,nan,'LineWidth',1);

line2 = plot(ax,nan,nan,'LineWidth',1);

line3 = plot(ax,nan,nan,'LineWidth',1);

line4 = plot(ax,nan,nan,'LineWidth',1);

lines = [line1 line2 line3 line4];

%% =========================================================
% AXIS
% ==========================================================

xlabel(ax,'Time (seconds)');

ylabel(ax,'EEG Channels');

title(ax,'BrainBit Live EEG');

%% =========================================================
% CHANNEL LABELS
% ==========================================================

channelLabels = {
    'Channel 1'
    'Channel 2'
    'Channel 3'
    'Channel 4'
};

% Channel 1 will be at the TOP.
% Channel 4 will be at the BOTTOM.

offsets = [
    3
    2
    1
    0
];

yticks(ax,[0 1 2 3]);

yticklabels(ax,{
    'Channel 4'
    'Channel 3'
    'Channel 2'
    'Channel 1'
});

ylim(ax,[-0.5 3.5]);
xlim(ax,[-windowSeconds 0]);

%% =========================================================
% RECEIVE EEG CONTINUOUSLY
% ==========================================================

while ishandle(fig)

    %% -----------------------------------------------------
    % RECEIVE LSL CHUNK
    % ------------------------------------------------------

    [chunk,timestamps] = inlet.pull_chunk();

    if isempty(chunk)

        pause(0.001);

        continue;

    end

    %% -----------------------------------------------------
    % CHUNK INFORMATION
    % ------------------------------------------------------

    chunkNumber = chunkNumber + 1;

    fprintf('\n=====================================\n');

    fprintf('Chunk %d\n',chunkNumber);

    fprintf('Raw chunk size : %d x %d\n', ...
        size(chunk,1),size(chunk,2));

    fprintf('Timestamp size : %d\n', ...
        length(timestamps));

    %% -----------------------------------------------------
    % CONVERT 4 x N TO N x 4
    % ------------------------------------------------------

    chunk = chunk';

    fprintf('After transpose: %d x %d\n', ...
        size(chunk,1),size(chunk,2));

    %% -----------------------------------------------------
    % CHECK CHANNEL COUNT
    % ------------------------------------------------------

    if size(chunk,2) ~= numChannels

        warning("Unexpected number of EEG channels.");

        continue;

    end

    %% -----------------------------------------------------
    % ADD CHUNK TO BUFFER
    % ------------------------------------------------------

    EEG = [EEG; chunk];

    %% -----------------------------------------------------
    % CREATE TIME VECTOR
    % ------------------------------------------------------

    numberOfSamples = size(chunk,1);

    if isempty(Time)

        startTime = 0;

    else

        startTime = Time(end) + 1/fs;

    end

    newTime = startTime + ...
        (0:numberOfSamples-1)' / fs;

    Time = [Time; newTime];

    %% -----------------------------------------------------
    % KEEP ONLY LAST 10 SECONDS
    % ------------------------------------------------------

    if size(EEG,1) > maxSamples

        EEG = EEG(end-maxSamples+1:end,:);

        Time = Time(end-maxSamples+1:end);

    end

    %% -----------------------------------------------------
    % REMOVE DC OFFSET
    % ------------------------------------------------------

    EEGplot = EEG - mean(EEG,1);

    %% -----------------------------------------------------
    % TIME FOR DISPLAY
    % ------------------------------------------------------

    TimePlot = Time - Time(end);

    %% -----------------------------------------------------
    % UPDATE CHANNEL 1
    % ------------------------------------------------------

    signal1 = EEGplot(:,1) * gain;

    signal1 = signal1 + offsets(1);

    set(line1, ...
        'XData',TimePlot, ...
        'YData',signal1);

    %% -----------------------------------------------------
    % UPDATE CHANNEL 2
    % ------------------------------------------------------

    signal2 = EEGplot(:,2) * gain;

    signal2 = signal2 + offsets(2);

    set(line2, ...
        'XData',TimePlot, ...
        'YData',signal2);

    %% -----------------------------------------------------
    % UPDATE CHANNEL 3
    % ------------------------------------------------------

    signal3 = EEGplot(:,3) * gain;

    signal3 = signal3 + offsets(3);

    set(line3, ...
        'XData',TimePlot, ...
        'YData',signal3);

    %% -----------------------------------------------------
    % UPDATE CHANNEL 4
    % ------------------------------------------------------

    signal4 = EEGplot(:,4) * gain;

    signal4 = signal4 + offsets(4);

    set(line4, ...
        'XData',TimePlot, ...
        'YData',signal4);

    %% -----------------------------------------------------
    % KEEP DISPLAY FIXED
    % ------------------------------------------------------

    xlim(ax,[-windowSeconds 0]);

    ylim(ax,[-0.5 3.5]);

    %% -----------------------------------------------------
    % DISPLAY SAMPLE INFORMATION
    % ------------------------------------------------------

    fprintf('Samples in buffer : %d\n',size(EEG,1));

    fprintf('First sample:\n');

    fprintf('%.6f  %.6f  %.6f  %.6f\n', ...
        chunk(1,1), ...
        chunk(1,2), ...
        chunk(1,3), ...
        chunk(1,4));

    fprintf('Last sample:\n');

    fprintf('%.6f  %.6f  %.6f  %.6f\n', ...
        chunk(end,1), ...
        chunk(end,2), ...
        chunk(end,3), ...
        chunk(end,4));

    %% -----------------------------------------------------
    % REFRESH FIGURE
    % ------------------------------------------------------

    drawnow limitrate;

end

disp("EEG receiver stopped.");
