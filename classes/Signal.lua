local Connection;

do
    local Class = {}
    
    function Class.New(Signal,Listener)
        local Object = {
            Connected = true
        }
        
        
        
        local Connections = Signal.Connections;
        
        Connections[Object] = Listener;
        
        
        
        local ObjectProxy = {}
        
        do
            function Object.Disconnect(ObjectProxy_)
                assert(ObjectProxy_ == ObjectProxy,"function call without a colon",2);
                
                Object.Connected = false;
            
                Connections[Object] = nil;
            end
        end
        
        return setmetatable(ObjectProxy,{
            __index = function(_ObjectProxy,Key)
                do
                    local Value = Object[Key];
                    
                    if (Value ~= nil) then
                        return Value;
                    end
                end
                
                --[[do
                    local Function = Functions[Key];
                    
                    if (Function ~= nil) then
                        return Function;
                    end
                end]]
            end,
            __metatable = "Connection",
            __newindex = function(_ObjectProxy,Key)
                error("attempt to modify a read-only key ("..tostring(Key)..")",2);
            end
        });
    end
    
    Connection = Class;
end



do
    local Class = {}
    
    
    
    function Class.New()
        local Object = {
            Connections = {}
        }
        
        function Object.Trigger(...)
            for _Connection,Listener in pairs(Object.Connections) do
                Listener(...);
            end
        end
        
        
        
        local ObjectProxy = {}
        
        return setmetatable(ObjectProxy,{
            -- Object = Object,
            __index = {
                Connect = function(ObjectProxy_,Listener)
                    assert(ObjectProxy_ == ObjectProxy,"function call without a colon",2);
                
                    do
                        local Listener_t = type(Listener);
                        
                        assert(Listener_t == "function","bad argument #1 to 'Connect' (function expected, got "..Listener_t..")",2);
                    end
                    
                    
                
                    return Connection.New(Object,Listener);
                end
            },
            __metatable = "Signal",
            __newindex = function(_ObjectProxy,Key)
                error("attempt to modify a read-only key ("..tostring(Key)..")",2);
            end
        }),Object.Connections,Object.Trigger;
    end
    
    
    
    Signal = Class;
end