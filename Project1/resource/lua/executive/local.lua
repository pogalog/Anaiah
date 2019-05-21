-- Local User Subsystem
Exec.localIsBusy = false;


function Exec.userActionStart()
	Exec.localIsBusy = true;
end


function Exec.userActionFinished()
	Exec.localIsBusy = false;
end


function Exec.isLocalCommitted()
	return Exec.localIsBusy;
end

