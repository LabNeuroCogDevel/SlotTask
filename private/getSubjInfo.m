%% helper function to get subject info and reload after failed run
function subject=getSubjInfo(taskname,subject,opts,blk)
  % opts need for genTimingOrder: opts.emofuncs,opts.numfaces,opts.trialsPerBlock,opts.stimtimes
  % which puts experiment into the subject structure
  
  
  totalBlocks = length(opts.blocktypes);
  
  
  %whether to prompt user for run to execute
  askRun=false;
  
  %determine subject number
  %if .mat file exists for this subject, then likely a reload and continue
  %subject.subj_id = NaN;
  while ~exist('subject','var') || ~ismember('subj_id', fields(subject)) ||  isnan(subject.subj_id)
      idInput = str2double(input('Enter the subject ID number: ','s')); %force to be numeric
      if ~isnan(idInput)
          subject.subj_id = idInput;
      else
          fprintf('\n  Subject id must be a number\n\n');
      end
  end
  
  %rundate
  c=clock();
  subject.run_date=c(1)*10000+c(2)*100+c(3);
  fprintf('rundate: %d\n',subject.run_date);
  
  filename = ['subjects/' taskname '_' num2str(subject.subj_id) '_' num2str(subject.run_date) '_tc'];
  subject.filename=filename; % export where we are saving things
  subject.matfile=[filename '.mat']; % export where we are saving things
  
  
  % is the subject new? should we resume from existing?
  % set t accordingly, maybe load subject structure
  subject.txtfile=[filename '.txt'];
  backup=[subject.txtfile '.' num2str(GetSecs()) '.bak'];
  
  % we did something with this subject before?
  if exist(subject.txtfile,'file') || exist(subject.matfile,'file')
      % check that we have a matching mat file
      % if not, backup txt file and restart
      if ~ exist(subject.matfile,'file')
          fprintf('%s exists, but (%s) does not!\n', subject.txtfile,subject.matfile)
          fprintf('moving %s to %s, start from top\n', subject.txtfile, backup)
          movefile(subject.txtfile, backup);
      else
          localVar = load(subject.matfile);
          
          % sanity check
          if localVar.subject.subj_id ~= subject.subj_id
              error('mat file data conflicts with name!: %d != %d',...
                  localVar.subject.subj_id, subject.subj_id);
          end
          
          %load previous information: place below above check to preserve user input
          subject=localVar.subject;
          % subject has order, experiment, i, score
          
          
      end
  end
  

  %% fill out the subject struct if any part of it is still empty
  
  % generate experiment (block (emotion+reward) and face number order
  if ~ismember('experiment',fields(subject)), 
    %[subject.experiment, subject.expercol2idx ] = genTimingOrder(opts.blocktypes,opts.trialsPerBlock,opts.stimtimes);
    [subject.experiment, subject.expercol2idx ] = getTimingOrder(opts.blocktypes);

    % initialize the order of events
    % this will be filled with "experiment" and behavioral actions/results (e.g. RT, ev, score)
    subject.order=zeros(size(subject.experiment,1),7);
  end

  %if new participant, assume run1 start and totally empt block Trials
  if ~ismember('run_num', fields(subject))
    subject.run_num = 1;
  end 
  if ~ismember('blockTrial', fields(subject))
    subject.blockTrial=zeros(1,totalBlocks);
  end
  
  
  % subjects age
  if ~ismember('age', fields(subject))
      subject.age = NaN;
      while isnan(subject.age)
          ageInput = str2double(input('Enter the subject''s age: ','s')); %force to be numeric
          if ~isnan(ageInput)
              subject.age = ageInput;
          else
              fprintf('\n  Subject age must be a number\n\n');
          end
      end
  else
      fprintf('using old age: %d\n', subject.age);
  end
  
  % gender is 'm' or 'f'
  if ~ismember('gender', fields(subject))
      subject.gender=[];
      while isempty(subject.gender)
          subject.gender = input(['Enter subject''s gender (m or f): '], 's');
          if ~(strcmpi(subject.gender, 'm') || strcmpi(subject.gender, 'f'))
              subject.gender=[];
          end
      end
  end

  % make sure sex is what we want
  if ismember(lower(subject.gender),{'male';'dude';'guy';'m';'1'} )
      subject.gender = 'male';
  else
      subject.gender = 'female';
  end
  
  % print out determined sex
  fprintf('Subject is %s\n', subject.gender);
  


  %% deal with run_number
  % blk we want, list of what we've done, the block order
  subject.run_num = chooseRun(blk,subject.blockTrial,subject.experiment(:,subject.expercol2idx('Block')));
  if(subject.run_num==0)
    error('no good block, not running')
  end

  % reset block list and score -- remove trials on the block we are going to try
  subject.order = resetOrder(subject.order,subject.run_num);
  
 
 %% set block type
 % opts.blocktypes = {'WINBLOCK','MOTOR','WINBLOCK','MOTOR'}; % TODO DECIDE ORDER
 % used only in determining display "WIN"/"####" or "NOWIN"/"|||"
 subject.blocktype= opts.blocktypes{subject.run_num};
 
 %% initialize timing -- TODO
 % subject.timing(trialnum,trialpart,:)
 
 %% show what we hve
 subject  
end
