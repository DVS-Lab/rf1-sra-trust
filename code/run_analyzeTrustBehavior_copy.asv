% analyze and aggregate trust task behavior across all subjects 
% make sure you run from the code directory so that paths are correct

clear all;

% set paths and output
codedir = pwd;
addpath(codedir);
basedir = pwd;
outdir = fullfile(basedir,'derivatives','behavioral');
if ~exist(outdir,'dir')
    mkdir(outdir);
end

sublist = [10369 10462 10608 10617 10657 10402 10418 10478 10529 10541 10572 10581 10585 10589 10596 10603 10606 10644 10656 10663 10673 10677];


fname = sprintf('summary_task-trust_desc-postOutcomeShifts-std.csv');
fid = fopen(fullfile(outdir,fname),'w');
fprintf(fid,'sub,computer_defect,computer_recip,stranger_defect,stranger_recip,friend_defect,friend_recip\n');
for s = 1:length(sublist)
    o = analyzeTrustBehavior(sublist(s));
    fprintf(fid,'sub-%d,%f,%f,%f,%f,%f,%f\n',sublist(s),o.computer_defect,o.computer_recip,o.stranger_defect,o.stranger_recip,o.friend_defect,o.friend_recip');
end
fclose(fid);
