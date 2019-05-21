-- Logger, for displaying information and debugging

Logger = {};
Logger.LEVEL_ERROR = 1;
Logger.LEVEL_INFO = 2;
Logger.LEVEL_DEBUG = 3;

Logger.level = Logger.LEVEL_INFO;

Logger.headers = {};
Logger.headers[Logger.LEVEL_ERROR] = "[ERROR]:";
Logger.headers[Logger.LEVEL_INFO] = "[INFO]:";
Logger.headers[Logger.LEVEL_DEBUG] = "[DEBUG]:";

-- TODO Maybe add support for varargs for appending additional messages
function Logger.format(level, msg)
    return Logger.headers[level] .. Global_clock .. ": " .. msg;
end

function Logger.ignore(msg) end

-- Error Functions
Logger.errfunc = {};
Logger.errfunc[Logger.LEVEL_ERROR] = function(msg)
    print(Logger.format(Logger.LEVEL_ERROR, msg));
end
Logger.errfunc[Logger.LEVEL_INFO] = Logger.errfunc[Logger.LEVEL_ERROR];
Logger.errfunc[Logger.LEVEL_DEBUG]= Logger.errfunc[Logger.LEVEL_ERROR];

-- Info Functions
Logger.infofunc = {};
Logger.infofunc[Logger.LEVEL_ERROR] = Logger.ignore;
Logger.infofunc[Logger.LEVEL_INFO] = function(msg)
    print(Logger.format(Logger.LEVEL_INFO, msg));
end
Logger.infofunc[Logger.LEVEL_ERROR] = Logger.infofunc[Logger.LEVEL_INFO];

-- Debug Functions
Logger.debugfunc = {};
Logger.debugfunc[Logger.LEVEL_ERROR] = Logger.ignore;
Logger.debugfunc[Logger.LEVEL_INFO] = Logger.ignore;
Logger.debugfunc[Logger.LEVEL_DEBUG] = function(msg)
    print(Logger.format(Logger.LEVEL_DEBUG, msg));
end


function Logger.error(msg)
    Logger.errfunc[Logger.level](msg);
end

function Logger.info(msg)
    Logger.infofunc[Logger.level](msg);
end

function Logger.debug(msg)
    Logger.debugfunc[Logger.level](msg);
end
            