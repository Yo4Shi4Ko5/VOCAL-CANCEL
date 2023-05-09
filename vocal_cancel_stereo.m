%{
���̃v���O�����͓���t�@�C�����ɑ��݂��鉹���f�[�^��p����B
�ݒ�̒l�͔C�ӂ̂��̂ŗǂ����A�{�[�J���L�����Z���݂̂ɒ��ڂ���Ȃ�
��ʂ�0�Amix��-10�œ��͂���ƃ{�[�J���L�����Z�������𓾂邱�Ƃ��o����B
�o�̓t�@�C�����͔C�ӂ̂��̂ŗǂ��B
%}

clear all
clc

% �Ȃ̐ݒ�
tune_name = input('�Ȃ̃t�@�C��������͂��Ă�������(�X�e���I�����̂�):', 's'); % ������ł���.m4a
[tune, fs] = audioread(tune_name);
tune1 = tune(:, 1);
tune2 = tune(:, 2);

finish_judge = 1;
while finish_judge == 1

    % ��ʂ̐ݒ�
    disp('--------------------------------------------------------------------------')
    pos_max = 10;
    s1 = sprintf('��ʂ̐ݒ���s���Ă�������(-%d�`%d)�B\n����ʂƂ́A���E�̃`�����l���̊����ł��B\n0���f�t�H���g -%d�͍��`�����l���̂� %d�͉E�`�����l���̂�:',...
        pos_max, pos_max, pos_max, pos_max);
    pos = pos_max + 1;
    while (pos<-1*pos_max | pos_max<pos)
        pos = input(s1);
    end
    if pos >= 0
        vocal_cancel = tune2 - (1 - pos/pos_max)*tune1;
    else
        vocal_cancel = tune1 - (1 + pos/pos_max)*tune2;
    end

    ori_mono = tune1 + tune2;

    % �t�B���^�����ݒ�
    if fs < 44100
        max_f = fs / 2;
    else
        max_f = 20000;
    end

    % ���[�p�X�t�B���^����
    disp('--------------------------------------------------------------------------')
    disp('�{�[�J���L�����Z������mix�����鉹�����쐬���܂��B')
    disp('�����Ƀ��[�p�X�t�B���^�ƃn�C�p�X�t�B���^�������܂��B')
    s2 = sprintf('\n���[�p�X�t�B���^�̎��g����ݒ肵�Ă�������(20�`%d):', max_f);
    low_f = max_f + 1;
    while (low_f < 20 | max_f < low_f)
        low_f = input(s2);
    end
    low_tune = lowpass(ori_mono, low_f, fs, 'Steepness', 0.95);

    % �n�C�p�X�t�B���^����
    s3 = sprintf('\n�n�C�p�X�t�B���^�̎��g����ݒ肵�Ă�������(20�`%d):', max_f);
    high_f = max_f + 1;
    while (high_f < 20 | max_f < high_f)
        high_f = input(s3);
    end
    high_tune = highpass(ori_mono, high_f, fs, 'Steepness', 0.95);

    ori_tune = low_tune + high_tune;

    % �~�b�N�X
    mix_max = 10;
    mix = mix_max + 1;
    s4 = sprintf('�{�[�J���L�����Z�����ƌ����̍���������-%d�`%d�͈̔͂Őݒ肵�Ă��������B\n(-%d�̓{�[�J���L�����Z�����̂� %d�͌����̂�):',...
        mix_max, mix_max, mix_max, mix_max);
    disp('--------------------------------------------------------------------------')
    while (mix<-1*mix_max | mix_max<mix)
        mix = input(s4);
    end

    if mix >= 0
        output_tune = ori_tune - (1 - mix/mix_max) * vocal_cancel;
    else
        output_tune = vocal_cancel - (1 + mix/mix_max) * ori_tune;
    end

    % �v���r���[
    preview_judge = 1;
    while preview_judge == 1
        tune_len = fix(length(tune1)/fs);
        disp('--------------------------------------------------------------------------')
        disp('�v���r���[���s���܂��B');
        s5 = sprintf('���̋Ȃ̒�����%d�b�ł��B', tune_len);
        disp(s5);
        s6 = sprintf('\n�v���r���[�̊J�n���Ԃ���͂��Ă�������(s):');
        s7 = sprintf('�v���r���[�̏I�����Ԃ���͂��Ă�������(s):');
        start_preview = tune_len+1;
        end_preview = tune_len+1;
        while start_preview >= end_preview
            start_preview = tune_len+1;
            end_preview = tune_len+1;
            while (start_preview<0 | tune_len<start_preview)
                start_preview = input(s6);
            end
            while (end_preview<0 | tune_len<end_preview)
                end_preview = input(s7);
            end
        end
        soundsc(output_tune(start_preview*fs+1:end_preview*fs), fs)
        pause(end_preview - start_preview)
        preview_judge = input('�v���r���[�𑱂��܂���?(1.�͂� 2.������):');
        while (preview_judge ~= 1 & preview_judge ~= 2)
            preview_judge = input('�v���r���[�𑱂��܂���?(1.�͂� 2.������):');
        end
    end
    
    disp('--------------------------------------------------------------------------')
    finish_judge = input('�ݒ����蒼���܂���?(1.�͂� 2.������):');
    while (finish_judge ~= 1 & finish_judge ~= 2)
        finish_judge = input('�ݒ����蒼���܂���?(1.�͂� 2.������):');
    end
end

% �t�@�C���̏����o��
file_name = input('�����o���t�@�C���̖��O����͂��Ă�������:', 's');
audiowrite(file_name, output_tune, fs)