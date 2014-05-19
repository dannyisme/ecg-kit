classdef progress_bar < handle

% Description:
% A progress-bar object to show the progress of a process. If the process
% is a loop, and the iteration number is known a priori, the object can inform
% the remaining time to finish the loop. If the iteration number is
% unknown, the object informs the mean duration of a loop.
% If the process is linear, the object can indicate the advance in the
% execution. The interface is very simple, and this example show the way of
% using it.
%
% Example:
% 
% %% start of algorithm
% clear
% 
% pb = progress_bar('Progress bar demo', 'Start of algorithm');
% 
% pause(2)
% 
% %% initialization code
% 
% pb.checkpoint('Initialization');
% 
% pause(4)
% 
% %% some iteration known a priori
% 
% pb.Loop2do = 10;
% pb.Title = 'Iterations known a priori';
% 
% for ii = 1:10
%     
%     pb.start_loop();
% 
%     pause(3+randn(1))
%     
%     pb.checkpoint('Step 1');
% 
%     pause(3+randn(1))
%     
%     pb.checkpoint('Step 2');
% 
%     pause(3+randn(1))
%     
%     pb.checkpoint('Step 3');
% 
%     pause(3+randn(1))
%     
%     pb.end_loop();
%     
% end
% 
% %% some iteration unknown a priori
% 
% pb.reset();
% pb.Title = 'Iterations Unknown a priori';
% 
% for ii = 1:round(8+2*rand(1))
%     
%     pb.start_loop();
% 
%     pause(3+randn(1))
%     
%     pb.checkpoint('Step 1');
% 
%     pause(3+randn(1))
%     
%     pb.checkpoint('Step 2');
% 
%     pause(3+randn(1))
%     
%     pb.checkpoint('Step 3');
% 
%     pause(3+randn(1))
%     
%     pb.end_loop();
%     
% end
% 
% %this clear and close all.
% clear pb
% 
% Limits and Known bugs:
% 
% Author: Mariano Llamedo Soria (llamedom at {electron.frba.utn.edu.ar; unizar.es}
% Birthdate  : 23/8/2011
% Last update: 24/3/2014

    properties(GetAccess = private, Constant)

        %constant for the waitbar
        bar_position = [0.05    0.3    0.9    0.25];
        default_evolution = 0.1;
        long_loop_in_sec = 10; % seconds
        
    end

    properties ( Access = private )
        bUIpresent = usejava('desktop');
        wb_handle = [];
        wb_axes_hdl = [];
        LoopTimes = [];
        counter = 0;
        obj_tic = [];
        Cleanup_hdl = [];
        bPBcreated = false;
    end

    properties(SetAccess = private, GetAccess = public)
        LoopMeanTime = [];
        LoopsDone = 0;
    end
    
    properties
        Message = '';
        Title = '';
        Loop2do = [];
    end
    
    methods 

        function obj = progress_bar(Title, Message)

            if( nargin > 0 && ischar(Title) )
                obj.Title = Title;
            end
                
            if( nargin > 1 && ischar(Message) )
                obj.Message = Message;
            end
            
            if( obj.bUIpresent )
                % log to a waitbar
                obj.wb_handle = waitbar(0, obj.Message, 'name', obj.Title );
                set(obj.wb_handle, 'Tag', 'progress_bar_class');
                obj.wb_axes_hdl = findobj(obj.wb_handle,'Type','Axes');
                set(obj.wb_axes_hdl, 'units','normalized' );
                set(obj.wb_axes_hdl, 'position',  obj.bar_position);
            else
                % TODO:log to stdout
                
            end
            
            %to clean and delete the waitbar.
%             obj.Cleanup_hdl = onCleanup(@()DoPBHouseKeeping(, obj.wb_handle));
            
            obj.bPBcreated = true;
            
        end
        
        function checkpoint(obj, Message )
        
            if( ischar(Message) )
                obj.Message = Message;
            end
            
            if( isempty(obj.LoopMeanTime) )
                %first loop, learning times. Just to show time evolution.
                obj.counter = obj.counter + obj.default_evolution;
                currTime = 0;
            else
                %estimate progress
                currTime = toc(obj.obj_tic);
                
                if( obj.LoopMeanTime > obj.long_loop_in_sec )
                    obj.counter = currTime/obj.LoopMeanTime;
                else
                    obj.counter = obj.LoopsDone/obj.Loop2do;
                end
            end 

            % take care always a waitbar to draw.
            if( ~ishandle(obj.wb_handle) )
                obj.wb_handle = waitbar(0);
                set(obj.wb_handle, 'Tag', 'progress_bar');
                obj.wb_axes_hdl = findobj(obj.wb_handle,'Type','Axes');
                set(obj.wb_axes_hdl, 'units','normalized' );
                set(obj.wb_axes_hdl, 'position', obj.bar_position );
            end

            waitbar( obj.counter - fix(obj.counter), obj.wb_handle, obj.Message );
            
            if( isempty(obj.LoopMeanTime) )
                if( ~isempty(obj.obj_tic) )
                    %Learning phase
                    set(obj.wb_handle, 'Name', [ obj.Title '. Learning loop time ...' ]);
                end
            else
                if( isempty(obj.Loop2do) )
                    set(obj.wb_handle, 'Name', [ adjust_string(obj.Title, 30) '. [' Seconds2HMS( obj.LoopMeanTime ) ' s/loop]']);
                else
                    set(obj.wb_handle, 'Name', [ adjust_string(obj.Title, 30) '. Finishing in ' Seconds2HMS((obj.Loop2do-obj.LoopsDone) * obj.LoopMeanTime - currTime) ]);
                end
            end
                
        end
        
        function start_loop(obj)
        
            %start of loop. Reset timers
            obj.obj_tic = tic;

            if( obj.LoopMeanTime > obj.long_loop_in_sec )
                % long process: progress within a loop.
                waitbar( 0, obj.wb_handle, 'Start of loop.' );
%             else
                % short process: total progress                 
            end
            
            
        end
        
        function end_loop(obj)
            
            %end of loop. Calculate averages.
            obj.LoopTimes = [obj.LoopTimes; toc(obj.obj_tic)];
            obj.LoopMeanTime = mean(obj.LoopTimes);
            obj.LoopsDone = obj.LoopsDone + 1;
            
            if( obj.LoopMeanTime > obj.long_loop_in_sec )
                % long process: progress within a loop.
                waitbar( 1, obj.wb_handle, 'End of loop.' );
%             else
                % short process: total progress                 
            end
            
            
        end
        
        function reset(obj)

            obj.LoopTimes = [];
            obj.LoopMeanTime = [];
            obj.counter = 0;
            obj.LoopsDone = 0;
            obj.Loop2do = [];
            obj.obj_tic = [];
            obj.Message = '';
            waitbar( 0, obj.wb_handle, obj.Message );
            set(obj.wb_handle, 'Name', obj.Title);
            
        end
        
        function set.Message(obj,value)
            if( ischar(value) )
                obj.Message = value;
                if( obj.bPBcreated )
                    waitbar( obj.counter - fix(obj.counter), obj.wb_handle, obj.Message );
                end
            else
                warning('progress_bar:BadArg', 'Message must be a string.');
            end
        end
        
        function set.Title(obj,value)
            if( ischar(value) )
                obj.Title = value;
                if( obj.bPBcreated )
                    set(obj.wb_handle, 'Name', obj.Title);
                end
            else
                warning('progress_bar:BadArg', 'Title must be a string.');
            end
        end
        
        function set.Loop2do(obj,value)
            if( isempty(value) || (isnumeric(value) && value > 0 ) )
                obj.Loop2do = value;
            else
                warning('progress_bar:BadArg', 'Loop2do must be a number > 1.');
            end
        end
        
        function delete(obj)
            if( obj.bUIpresent )
                if( ishandle(obj.wb_handle) ) 
                    % waitbar close
                    delete(obj.wb_handle)
                end
            else

            end
            
        end
        
    end

end

