clear all; close all; clc

cd('C:\Users\u0167448\Documents\Data\2004\ultrasound')

%%
vidname = 'p4 c240 2 20260420 160659';
vidobj = VideoReader([vidname, '.mp4']);
type = 'last 15 s reduced';

%%

if contains(type, 'last 15 s')
    % last 15 seconds
    f = read(vidobj, [vidobj.NumFrames-(15*100) vidobj.NumFrames]);
else
    % first 30 seconds
    f = read(vidobj, [1 30*100]);
end

if contains(type, 'reduced')
    f = imresize(f, 0.5);
end

%%
vidObj2 = VideoWriter([vidname ' - ', type], 'MPEG-4');
vidObj2.FrameRate = 100;

open(vidObj2);

for k = 1:size(f,4)
    disp(k)
   writeVideo(vidObj2, f(:,:,:,k));
end

% Close the file.
close(vidObj2);