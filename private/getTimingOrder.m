% take cell of blocktypes (
% return matrix experiment and function to get column names
function [experiment, col2idx ] = getTimingOrder(blocktypes)

  % useful function, makes () anonymous
  paren = @(x, varargin) x(varargin{:});

  % function to get the index of a trial component within the experiement matrix
  %i.e. label columns :: translates column name into index
  col2idx = @(name) find(cellfun(@(x) any(strmatch(x,name)),{'Block','Spin','Result','ITI','WIN','Score'}));
  % because winblocks are set in options (getOpts)
  % Score column added later in SlotTask.m via
  %   canreward = cellfun(@(x) strcmp(x,'WINBLOCK'), opts.blocktypes(subject.experiment(:,colIDX('Block') ) ));
  %   subject.experiment(:,colIDX('Score')) = cumsum(subject.experiment(:,colIDX('WIN')) .* canreward');
  %

  numblocks = length(blocktypes);

  % find all mat files in the mats directory
  %   -- and padding to each file name ('.' and '..' too) 
  %      and reverse so we can test for mat ending 
  %      even on strigns that are too short 
  allfiles=dir(fullfile('timing','mats'));
  files={allfiles.name};
  matfileidx=find(cellfun( @(x) all(paren(fliplr(['padding' x]),1:3)=='tam'), files));

  % quick fix if we dont have enough mat files
  if(length(matfileidx)<numblocks)
   matfileidx=RandSample(matfileidx,[1 numblocks]);
   warning('too few mat files in timing/mats, randomly sampled with what we have')
  end

  
  % shuffle up the order
  mfiorder=randsample(matfileidx,numblocks);
  
  % and undo all that hard work
  % for the piolot we have an order we want to stick to
  matfileidx=find(cellfun( @(x) all(paren(fliplr(['padding' x]),1:3)=='tam'), files));
  mfiorder= [ matfileidx(1:4) matfileidx(1:4) ];
  
  % initialize an experiment matrix, we dont know how long it will be
  experiment=[];
  
  for i=1:length(mfiorder)
      fprintf('%d: %s\n',i,files{mfiorder(i)});
  end

  for bn=1:numblocks
    matfile=files{mfiorder(bn)};

    % tmpexp.block is c(spinlen,resultlen,ITIlen,score), see timing/timingFromAfni.R
    tmpexp = load(fullfile('timing','mats', matfile  ));

    % cut the num of trials if we are debuging
    %if( opts.DEBUG==1)
    %    tmpexp.block = tmpexp.block(1:7,:);
    %end
    
    % column to identify this block
    blockcol=ones(size(tmpexp.block,1),1).*bn;

    % build the experiment block by block, appending the block number to the matrix in the mat file generated by R
    experiment=[experiment; blockcol tmpexp.block ];


  end
  
  
  

  

end
