StriLi = LibStub("AceAddon-3.0"):NewAddon("StriLi", "AceConsole-3.0");
StriLi.Lang = {
    ErrorMsg = {
        ExpectNumAsItemID = "Expected number as ItemID!",
        ExpectNumAsTime = "Expected number as time!",
        CombineMembers1 = "Combine of members",
        CombineMembers2 = "and",
        CombineMembers3 = "failed, while receiving Data Changed Msg.",
        MasterInitFail = "Master can not be initialized",
        Argument = "Argument",
        IsNotString = "is not a string type.",
        IsNotItemLink = "is not an item link.",
        IsNotNumber = "is not a number type.",
        RemoveOnlineRaidmember = "You can't remove online raidmembers from StriLi.",
    },
    Rolls = {
        StartRoll1 = "Es wird um das Item ",
        StartRoll2 = " gewürfelt. Du hast ",
        StartRoll3 = " Sekunden zeit.",
        TallyMarks = "Striche",
        Fails = "Fails",
        Roll = "Roll",
        NoRollToCancel = "No roll to cancel in progress.",
        RollCanceled = "Roll canceled.",
        RollAlreadyInProgress = "You have already a roll in progress. To cancel a current roll type",
    },
    TallyMarkTypes = {
        Main = "Main",
        Sec = "Sec",
    },
    Name = "Name",
    version = "version",
    loaded = "loaded",
    Commands = {
        InvalideNotInRaid = "Invalide command. You're not in a Raid.",
        AvailableCommands = "Available commands",
        TimeInSec = "time in s",
        NoPermRankToLow = "No permission. Your Rank is to low.",
        FirstArgNum = "First argument must be a NUMBER."
    },
    Confirm = {
        RaidLeftResetData = "Du hast den Raid verlassen. Möchtest du alle Daten zurücksetzen?",
        NewRaidResetData = "Du hast eine neue Raid-Gruppe betreten. Möchtest du alle Daten zurücksetzen?",
        ResetDataConfirm = "Bist du sicher, das du alle Daten zurücksetzen willst?",
    },
    Labels = {
        Name = "Name",
        Reregister = "U",
        Main = "Main",
        Sec = "Sec",
        Token = "Token",
        Fail = "Fail",
        Lock = "Lock",
        Unlock = "Unlock",
        Ascending = "'",
        Descending = ",",
        Class = "Klasse",
    }
};