%{
このプログラムは同一ファイル内に存在する音源データを用いる。
設定の値は任意のもので良いが、ボーカルキャンセルのみに着目するなら
定位を0、mixを-10で入力するとボーカルキャンセル音源を得ることが出来る。
出力ファイル名は任意のもので良い。
%}

clear all
clc

% 曲の設定
tune_name = input('曲のファイル名を入力してください(ステレオ音源のみ):', 's'); % いいんですか.m4a
[tune, fs] = audioread(tune_name);
tune1 = tune(:, 1);
tune2 = tune(:, 2);

finish_judge = 1;
while finish_judge == 1

    % 定位の設定
    disp('--------------------------------------------------------------------------')
    pos_max = 10;
    s1 = sprintf('定位の設定を行ってください(-%d～%d)。\n※定位とは、左右のチャンネルの割合です。\n0がデフォルト -%dは左チャンネルのみ %dは右チャンネルのみ:',...
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

    % フィルタ処理設定
    if fs < 44100
        max_f = fs / 2;
    else
        max_f = 20000;
    end

    % ローパスフィルタ処理
    disp('--------------------------------------------------------------------------')
    disp('ボーカルキャンセル音とmixさせる音源を作成します。')
    disp('原音にローパスフィルタとハイパスフィルタをかけます。')
    s2 = sprintf('\nローパスフィルタの周波数を設定してください(20～%d):', max_f);
    low_f = max_f + 1;
    while (low_f < 20 | max_f < low_f)
        low_f = input(s2);
    end
    low_tune = lowpass(ori_mono, low_f, fs, 'Steepness', 0.95);

    % ハイパスフィルタ処理
    s3 = sprintf('\nハイパスフィルタの周波数を設定してください(20～%d):', max_f);
    high_f = max_f + 1;
    while (high_f < 20 | max_f < high_f)
        high_f = input(s3);
    end
    high_tune = highpass(ori_mono, high_f, fs, 'Steepness', 0.95);

    ori_tune = low_tune + high_tune;

    % ミックス
    mix_max = 10;
    mix = mix_max + 1;
    s4 = sprintf('ボーカルキャンセル音と原音の混合割合を-%d～%dの範囲で設定してください。\n(-%dはボーカルキャンセル音のみ %dは原音のみ):',...
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

    % プレビュー
    preview_judge = 1;
    while preview_judge == 1
        tune_len = fix(length(tune1)/fs);
        disp('--------------------------------------------------------------------------')
        disp('プレビューを行います。');
        s5 = sprintf('この曲の長さは%d秒です。', tune_len);
        disp(s5);
        s6 = sprintf('\nプレビューの開始時間を入力してください(s):');
        s7 = sprintf('プレビューの終了時間を入力してください(s):');
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
        preview_judge = input('プレビューを続けますか?(1.はい 2.いいえ):');
        while (preview_judge ~= 1 & preview_judge ~= 2)
            preview_judge = input('プレビューを続けますか?(1.はい 2.いいえ):');
        end
    end
    
    disp('--------------------------------------------------------------------------')
    finish_judge = input('設定をやり直しますか?(1.はい 2.いいえ):');
    while (finish_judge ~= 1 & finish_judge ~= 2)
        finish_judge = input('設定をやり直しますか?(1.はい 2.いいえ):');
    end
end

% ファイルの書き出し
file_name = input('書き出すファイルの名前を入力してください:', 's');
audiowrite(file_name, output_tune, fs)