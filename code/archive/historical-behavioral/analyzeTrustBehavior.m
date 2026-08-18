% Get the path of the current script
scriptname = matlab.desktop.editor.getActiveFilename;

% Get the directory containing the current script
[codedir, ~, ~] = fileparts(scriptname);
cd(codedir);
addpath(codedir);
cd ..

maindir = '/ZPOOL/data/projects/rf1-sra-data';
rawdata = '/ZPOOL/data/projects/rf1-sra-data/bids/';
basedir = '/ZPOOL/data/projects/rf1-sra-trust';
outdir = fullfile(basedir, 'derivatives', 'behavioral');
if ~exist(outdir, 'dir')
    mkdir(outdir);
end

sublist = [10402
10418
10462
10478
10486
10529
10541
10559
10572
10581
10584
10585
10589
10590
10596
10603
10606
10608
10617
10636
10638
10640
10641
10642
10644
10647
10649
10652
10656
10657
10661
10663
10668
10673
10674
10677
10685
10690
10691
10700
10701
10713
10716
10718
10720
10723
10741
10748
10767
10770
10777
10781
10783
10785
10794
10801
10802
10803
10804
10806
10807
10809
10810
10812
10817
10827
10831
10834
10838
10843
10850
10854
10857
10858
10860
10862
10863
10866
10875
10887
10896
10898
10908
10918
10924
10930
10938
10940
10950
10952
10953
10954
10956
10958
10969
10974
10977
10983
10984
11005
11031];

fname = sprintf('summary_task-trust_desc-postOutcomeShifts-std.csv');
fid = fopen(fullfile(outdir, fname), 'w');
fprintf(fid, 'sub,computer_defect,computer_recip,stranger_defect,stranger_recip,friend_defect,friend_recip\n');

for s = 1:length(sublist)
    try
        [onsets, trial_type, RT, trust_value] = deal([]);
        for r = 0:1
            input = fullfile(rawdata, ['sub-', num2str(sublist(s))], 'func', sprintf('sub-%d_task-trust_run-%d_events.tsv', sublist(s), r + 1));
            infile = fullfile(input);
            
            % Check if the input file exists
            if exist(infile, 'file')
                fid_data = fopen(infile, 'r');
                C = textscan(fid_data, '%f%f%s%f%s%s%d%d', 'Delimiter', '\t', 'HeaderLines', 1, 'EmptyValue', NaN);
                fclose(fid_data);
            else
                fprintf('sub-%d -- Investment Game, Run %d: No data found.\n', sublist(s), r + 1);
                continue;
            end
            
            onsets = [onsets; C{1}];
            trial_type = [trial_type; C{3}];
            RT = [RT; C{4}];
            trust_value = [trust_value; C{5}];
        
        % get friend trials and adjust for recip/defect on previous trial
        friend_trials = trial_type(startsWith(trial_type(:),'outcome_friend'));
        friend_trials(end) = []; % removes last element
        friend_values = str2num(cell2mat(trust_value(startsWith(trial_type(:),'outcome_friend'))));
        %friend_values = RT(startsWith(trial_type(:),'outcome_friend'));
        friend_values(1) = []; % removes first element. now everything is linked to the previous outcome with this partner
        
        % get stranger trials and adjust for recip/defect on previous trial
        stranger_trials = trial_type(startsWith(trial_type(:),'outcome_stranger'));
        stranger_trials(end) = [];
        stranger_values = str2num(cell2mat(trust_value(startsWith(trial_type(:),'outcome_stranger'))));
        %stranger_values = RT(startsWith(trial_type(:),'outcome_stranger'));
        stranger_values(1) = [];
        
        
        % get computer trials and adjust for recip/defect on previous trial
        computer_trials = trial_type(startsWith(trial_type(:),'outcome_computer'));
        computer_trials(end) = [];
        computer_values = str2num(cell2mat(trust_value(startsWith(trial_type(:),'outcome_computer'))));
        %computer_values = RT(startsWith(trial_type(:),'outcome_computer'));
        computer_values(1) = [];
        

    
    output.computer_defect = mean(computer_values(endsWith(computer_trials(:),'defect')));
    output.computer_recip = mean(computer_values(endsWith(computer_trials(:),'recip')));
    
    output.stranger_defect = mean(stranger_values(endsWith(stranger_trials(:),'defect')));
    output.stranger_recip = mean(stranger_values(endsWith(stranger_trials(:),'recip')));
    
    output.friend_defect = mean(friend_values(endsWith(friend_trials(:),'defect')));
    output.friend_recip = mean(friend_values(endsWith(friend_trials(:),'recip'))); 

        end

        % Write data for the current subject to the output file
        fprintf(fid, 'sub-%d,%f,%f,%f,%f,%f,%f\n', sublist(s), output.computer_defect, output.computer_recip, output.stranger_defect, output.stranger_recip, output.friend_defect, output.friend_recip);

    end
end

% Close the output file
fclose(fid);