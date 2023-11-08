% analyze and aggregate trust task behavior across all subjects 
% make sure you run from the code directory so that paths are correct

clear all;

% set paths and output
codedir = pwd;
addpath(codedir);
basedir = fileparts(codedir);
outdir = fullfile(basedir,'derivatives','behavioral');
if ~exist(outdir,'dir')
    mkdir(outdir);
end

sublist = [10317 10369 10391 10402 10418 10462 10478 10486 10529 10541 10555 10559 10572 10581 10584 10585 10589 10590 10596 10603 10606 10608 10617 10636 10638 10640 10641 10642 10644 10647 10649 10652 10656 10657 10659 10661 10663 10668 10673 10674 10677 10685 10690 10691 10700 10701 10713 10716 10718 10720 10723 10741 10748 10767 10770 10774 10777 10781 10783 10785 10794 10800 10801 10802 10803 10804 10806 10807 10809 10812];


fname = sprintf('summary_task-trust_desc-postOutcomeShifts-std.csv');
fid = fopen(fullfile(outdir,fname),'w');
fprintf(fid,'sub,computer_defect,computer_recip,stranger_defect,stranger_recip,friend_defect,friend_recip\n');
for s = 1:length(sublist)
    o = analyzeTrustBehavior(sublist(s));
    fprintf(fid,'sub-%d,%f,%f,%f,%f,%f,%f\n',sublist(s),o.computer_defect,o.computer_recip,o.stranger_defect,o.stranger_recip,o.friend_defect,o.friend_recip');
end
fclose(fid);
