StriLi = LibStub("AceAddon-3.0"):NewAddon("StriLi", "AceConsole-3.0");
StriLi.Lang = {
    ErrorMsg = {
        ExpectNumAsItemID = "Expected number as ItemID!",
        ExpectNumAsTime = "Expected number as time!",
        CombineMembers1 = "Combine of members",
        CombineMembers2 = "and",
        CombineMembers3 = "failed, while receiving DataChanged Msg.",
        MasterInitFail = "Master can not be initialized",
        Argument = "Argument",
        IsNotString = "is not a string type.",
        IsNotItemLink = "is not an item link.",
        IsNotNumber = "is not a number type.",
        RemoveOnlineRaidmember = "You can't remove online raidmembers from StriLi.",
        ObserverImplement = "observer must implement OnValueChanged",
        SetMasterNotPossible = "kann nicht zum Master ernannt werden.",
        RankToLow = "Rang zu niedrig",
        PlayerNotInRaid = "befindet sich nicht in der Raidgruppe.",
        PossibleCauses = "Mögliche Ursachen",
        Cause1 = "ist Ausgeloggt.",
        Cause2 = "hat einen Disconect.",
        Cause3 = "Du hast einen Disconect.",
        Cause4 = "hat StriLi nicht.",
        Cause5 = "hat eine stark veraltete Version von StriLi.",
    },
    Rolls = {
        StartRoll1 = "Es wird um das Item ",
        StartRoll2 = " gewürfelt. Du hast ",
        StartRoll3 = " Sekunden Zeit.",
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
        CombineMembers = "Zusammenlegen mit",
        Reregister = "Ummelden",
        SetMaster = "Zu Master ernennen",
        Remove = "Entfernen",
    },
    Confirm = {
        RaidLeftResetData = "Du hast den Raid verlassen. Möchtest du alle Daten zurücksetzen?",
        NewRaidResetData = "Du hast eine neue Raid-Gruppe betreten. Möchtest du alle Daten zurücksetzen?",
        ResetDataConfirm = "Bist du sicher, das du alle Daten zurücksetzen willst?",
        ReregisterRequest = "Gib den Spec an auf den Umgemeldet wird",
        AreYouSureTo = "Bist du sicher, dass du",
        SetMaster = "zum Master ernennen möchtest?",
        Remove = "entfernen möchtest?",
        Combine1 = "mit",
        Combine2 = "zusammenlegen möchtest?",
        Combine3 = "wird behalten)",
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
    },
    XML = {
        ButtonYes = "Yes",
        ButtonCancel = "Cancel",
        ButtonReset = "Reset",
        ButtonSync = "Sync",
        ButtonLock = "Lock",
        ButtonSort = "Sort",
        ButtonItemHistory = "ItemHistory",
        NewStriLiVersion = "Eine neue Version von StriLi ist verfügbar unter:",
        ButtonOk = "Ok",
        LootRules = "Loot Rules",
    },
};

function StriLi.InitLang()

    local lang = GetLocale();

    if lang == "deDE" then
        StriLi.Lang = StriLi_Stub_deDE();
    elseif lang == "enGB" or lang == "enUS" then
        StriLi.Lang = StriLi_Stub_enGB();
    else
        error("WTF?!");
    end

end