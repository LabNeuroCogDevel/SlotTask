function opts=getopts(varargin)
  varargin=varargin{:};
  %% MEG BY DEFAULT
  opts.DEBUG=0;
  opts.test=0;
  opts.sound=0;

  %% Default scren size (MEG center)
  opts.screen=[1280 1024];
  
  %% %% set stimtimes
  %% % ranges IN MILLISECONDS
  %% %stimtimes.ITI.min=300; stimtimes.ITI.max=300; stimtimes.ITI.mean=300;
  %% %stimtimes.ISI.min=1000;stimtimes.ISI.max=1500;stimtimes.ISI.mean=1250;
  %% stimtimes.ITI.min=2000; stimtimes.ITI.max=8000; stimtimes.ITI.dist='exp';
  %% stimtimes.ISI.min=2000;stimtimes.ISI.max=8000;  stimtimes.ISI.dist='exp';
  %% % hard coded times, in SECONDS
  %% stimtimes.Spin    = 0.5;
  %% stimtimes.Result  = 0.5;
  %% stimtimes.Receipt = 1.0;
  
  %opts.stimtimes      = stimtimes;
  
  %% define deafult paradigm for experiment
  opts.blocktypes = {'MOTOR','MOTOR','MOTOR','MOTOR','WINBLOCK','WINBLOCK','WINBLOCK','WINBLOCK'}; 
  % will be setup in subject info -> genTimingOrder

  
  %% PARSE REST
  i=1;
  while(i<=length(varargin))
      switch varargin{i}
          case {'DEBUG'}
              opts.DEBUG=1;
              opts.blocktypes = {'WINBLOCK','MOTOR'};
              opts.screen=[800 600];
              %opts.trialsPerBlock=7; % to get at least one win
          case {'nopet'}
              opts.blocktypes={'WINBLOCK','WINBLOCK','WINBLOCK','WINBLOCK'};
              
          case {'screen'}
              i=i+1;
              if isa(varargin{i},'char')
                  
                % SlotTask('screen','eyelab')
                switch varargin{i}
                    case {'mac laptop'}
                        opts.screen=[1680 1050]; %mac laptop
                    case {'VGA'}
                        opts.screen=[640 480]; %basic VGA
                    case {'eyelab'}
                        opts.screen=[1440 900]; %new eyelab room
                    otherwise
                        fprintf('dont know what %s is\n',varargin{i});
                end
                
              %TASK...('screen',[800 600])
              else
                opts.screen=varargin{i};    
              end    

          otherwise
              fprintf('unknown option #%d\n',i)
      end
      
   i=i+1;    
  
  end
  
  
  disp(opts)
end

