clear;
clc;

disp("Loading LSL library...");
lib = lsl_loadlib();

disp("Looking for EEG stream...");
result = {};

while isempty(result)
    result = lsl_resolve_byprop(lib,'type','EEG');
    pause(1);
end

disp("EEG stream found!");

inlet = lsl_inlet(result{1});

disp("Receiving EEG samples...");

while true
    [sample, timestamp] = inlet.pull_sample();

    fprintf('Time: %.3f\n', timestamp);
    disp(sample);
end
