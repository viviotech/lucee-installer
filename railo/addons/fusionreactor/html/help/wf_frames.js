function DoCommand(cmd, param) {
	if (cmd == "CmdAskIsTopicOnly")	{
		if( (parent!=this) && (parent.DoCommand) )
		{
			parent.DoCommand(cmd, param);	
		}
	}
}