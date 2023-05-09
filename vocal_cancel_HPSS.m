%{
���̃v���O�����͎��s����ƁA�w�肵�Ă��鉹���t�@�C����
���dHPSS�������{����H�̉����𓾂邱�Ƃ��o����B
�C�ӂ̉�������͉\�B
%}

clear all
clc

[tune, fs] = audioread('������ł���.m4a');
tune1 = tune(:, 1);
tune2 = tune(:, 2);

% 1��ڂ�HPSS
win = sqrt(hann(1024, 'periodic'));
overlapLength = floor(numel(win)/2);
fftLength = 2^nextpow2(numel(win)+1);
y = stft(tune1, 'Window', win, 'OverlapLength', overlapLength, 'FFTLength', fftLength, 'Centered', true);
halfIdx = 1:ceil(size(y, 1)/2);
yhalf = y(halfIdx, :);
ymag = abs(yhalf);

timeFilterLength = 1;
timeFilterLengthInSamples = timeFilterLength/((numel(win) - overlapLength)/fs);
ymagharm = movmedian(ymag, timeFilterLengthInSamples, 2);

frequencyFilterLength = 500;
frequencyFilterLengthInSamples = frequencyFilterLength/(fs/fftLength);
ymagperc = movmedian(ymag, frequencyFilterLengthInSamples, 1);

totalMagnitudePerBin = ymagharm + ymagperc;

harmonicMask = ymagharm > (totalMagnitudePerBin*0.5);
percussiveMask = ymagperc > (totalMagnitudePerBin*0.5);

yharm = harmonicMask.*yhalf;
yperc = percussiveMask.*yhalf;

yharm = cat(1, yharm, flipud(conj(yharm)));
yperc = cat(1, yperc, flipud(conj(yperc)));

h = istft(yharm, 'Window', win, 'OverlapLength', overlapLength, ...
    'FFTLength', fftLength, 'ConjugateSymmetric', true);
p = istft(yperc, 'Window', win, 'OverlapLength', overlapLength, ...
    'FFTLength', fftLength, 'ConjugateSymmetric', true);

% 2��ڂ�HPSS
y = stft(p, 'Window', win, 'OverlapLength', overlapLength, 'FFTLength', fftLength, 'Centered', true);

halfIdx = 1:ceil(size(y, 1)/2);
yhalf = y(halfIdx, :);
ymag = abs(yhalf);

timeFilterLength = 0.01;
timeFilterLengthInSamples = timeFilterLength/((numel(win) - overlapLength)/fs);
ymagharm = movmedian(ymag, timeFilterLengthInSamples, 2);

frequencyFilterLength = 500;
frequencyFilterLengthInSamples = frequencyFilterLength/(fs/fftLength);
ymagperc = movmedian(ymag, frequencyFilterLengthInSamples, 1);

totalMagnitudePerBin = ymagharm + ymagperc;

harmonicMask = ymagharm > (totalMagnitudePerBin*0.5);
percussiveMask = ymagperc > (totalMagnitudePerBin*0.5);

yharm = harmonicMask.*yhalf;
yperc = percussiveMask.*yhalf;

yharm = cat(1, yharm, flipud(conj(yharm)));
yperc = cat(1, yperc, flipud(conj(yperc)));

h = istft(yharm, 'Window', win, 'OverlapLength', overlapLength, ...
    'FFTLength', fftLength, 'ConjugateSymmetric', true);
p = istft(yperc, 'Window', win, 'OverlapLength', overlapLength, ...
    'FFTLength', fftLength, 'ConjugateSymmetric', true);

soundsc(h(1:1500000), fs)