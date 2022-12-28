function StriLi_Stub_enGB() return {
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
        ObserverImplement = "observer must implement OnValueChanged",
        SetMasterNotPossible = "cant be set as master.",
        RankToLow = "rank to low",
        PlayerNotInRaid = "is not in your raid.",
        PossibleCauses = "Possible causes",
        Cause1 = "is logged off.",
        Cause2 = "is disconnected.",
        Cause3 = "You've got a disconnect.",
        Cause4 = "doesn't have StriLi.",
        Cause5 = "has an outdated StriLi version.",
        ItemReassignFailed = "The assignment of the item %s to %s failed. The tally marks of %s were 0.",
        ItemRemoveFailed = "Removing the item failed because %s has 0 tally marks.",
    },
    Rolls = {
        StartRoll1 = "Roll for Item ",
        StartRoll2 = " starts. You've got ",
        StartRoll3 = " seconds to roll.",
        TallyMarks = "Tally marks",
        Fails = "Fails",
        Roll = "Roll",
        NoRollToCancel = "No roll to cancel in progress.",
        RollCanceled = "Roll canceled.",
        RollAlreadyInProgress = "You have already a roll in progress. To cancel a current roll type",
        RollReassigned = "Edited",
    },
    TallyMarkTypes = {
        Main = "Main",
        Sec = "Sec",
        Token = "Token",
        Fail = "Fail",
    },
    Name = "Name",
    version = "version",
    loaded = "loaded",
    Commands = {
        InvalideNotInRaid = "Invalide command. You're not in a Raid.",
        AvailableCommands = "Available commands",
        TimeInSec = "time in s",
        NoPermRankToLow = "No permission. Your Rank is to low.",
        FirstArgNum = "First argument must be a NUMBER.",
        PlayersGotLoot = "Players that got no Loot",
        CombineMembers = "Combine with",
        Reregister = "Reregister",
        SetMaster = "Set as master",
        Remove = "Remove",
        YourNotMaster = "You are not the StriLi master.",
        PlayerChange = "Assign to another player",
    },
    Confirm = {
        RaidLeftResetData = "You have left the raid. Do you want to reset all data?",
        NewRaidResetData = "You have entered a new raid group. Do you want to reset all data?",
        ResetDataConfirm = "Are you sure you want to reset all data?",
        ReregisterRequest = "Specify the spec to which you want to change the registration to",
        SyncDataConfirm = "You are StriLi Master. Are you sure you want to synchronize the data? Your data will be overwritten.",
        AreYouSureTo = "Are you sure ",
        SetMaster = " should be set as master?",
        Remove = "should be removed?",
        Combine1 = "and",
        Combine2 = "should be combined?",
        Combine3 = "will be retained)",
        ItemAssign = "should be assigned as the new owner of this Item?",
        ItemRemove = "Are you sure you want to remove the item?",
    },
    Labels = {
        Name = "Name",
        Reregister = "R",
        Main = "Main",
        Sec = "Sec",
        Token = "Token",
        Fail = "Fail",
        Lock = "Lock",
        Unlock = "Unlock",
        Ascending = "'",
        Descending = ",",
        Class = "Class",
    },
    XML = {
        ButtonYes = "Yes",
        ButtonCancel = "Cancel",
        ButtonReset = "Reset",
        ButtonSync = "Sync",
        ButtonLock = "Lock",
        ButtonSort = "Sort",
        ButtonSave = "Save",
        ButtonItemHistory = "ItemHistory",
        NewStriLiVersion = "A new version of StriLi is available at:",
        ButtonOk = "Ok",
        LootRules = "Loot Rules",
    },
};
end