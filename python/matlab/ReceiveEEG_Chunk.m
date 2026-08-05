clear;
clc;

%% Load LSL
disp("Loading LSL library...");
lib = lsl_loadlib();

%% Find EEG Stream
disp("Looking for EEG stream...");
result = {};

while isempty(result)
    result = lsl_resolve_byprop(lib,'type','EEG');
    pause(1);
end

disp("EEG stream found!");

%% Create inlet
inlet = lsl_inlet(result{1});

disp("Receiving EEG chunks for 10 seconds...");

EEG = [];
Time = [];

chunkNumber = 0;

startTime = tic;

while toc(startTime) < 10

    % Receive chunk
    [chunk, timestamps] = inlet.pull_chunk();

    % Skip empty chunk
    if isempty(chunk)
        pause(0.01);
        continue;
    end

    % Make sure chunk is Nx4
    if size(chunk,1) == 4
        chunk = chunk';
    end

    % Store data
    EEG = [EEG; chunk];

    if size(timestamps,1) == 1
        timestamps = timestamps';
    end

    Time = [Time; timestamps];

    chunkNumber = chunkNumber + 1;

    fprintf("\n=====================================\n");
    fprintf("Chunk %d received\n", chunkNumber);
    fprintf("Samples in chunk: %d\n", size(chunk,1));
    fprintf("=====================================\n");

    % Print every sample inside chunk
    for i = 1:size(chunk,1)

        fprintf("Sample %3d | Time %.3f | ", ...
            i, timestamps(i));

        fprintf("Ch1: %.4f  ", chunk(i,1));
        fprintf("Ch2: %.4f  ", chunk(i,2));
        fprintf("Ch3: %.4f  ", chunk(i,3));
        fprintf("Ch4: %.4f\n", chunk(i,4));

    end

end

disp("--------------------------------");
disp("Finished receiving.");
fprintf("Total chunks : %d\n", chunkNumber);
fprintf("Total samples: %d\n", size(EEG,1));

%% Save

save('BrainBit_EEG_Chunk.mat','EEG','Time');

disp("Saved as BrainBit_EEG_Chunk.mat");

%% Plot

figure;

plot(Time-Time(1),EEG(:,1),'LineWidth',1);
hold on
plot(Time-Time(1),EEG(:,2),'LineWidth',1);
plot(Time-Time(1),EEG(:,3),'LineWidth',1);
plot(Time-Time(1),EEG(:,4),'LineWidth',1);

xlabel('Time (seconds)');
ylabel('Amplitude');
title('BrainBit EEG (Chunk Reception)');
legend('Ch1','Ch2','Ch3','Ch4');
grid on;

disp("Plot generated successfully.");
