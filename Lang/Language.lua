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
        SetAssistNotPossible = "kann nicht zum StriLi-Assist ernannt werden.",
        RankToLow = "Rang zu niedrig",
        PlayerNotInRaid = "befindet sich nicht in der Raidgruppe.",
        PossibleCauses = "Mögliche Ursachen",
        Cause1 = "ist Ausgeloggt.",
        Cause2 = "hat einen Disconect.",
        Cause3 = "Du hast einen Disconect.",
        Cause4 = "hat StriLi nicht.",
        Cause5 = "hat eine stark veraltete Version von StriLi.",
        ItemReassignFailed = "Das Zuweisen des Items %s an %s ist fehlgeschlagen. Die Striche von %s waren 0.",
        ItemRemoveFailed = "Das entfernen des Items ist fehlgeschlagen, da %s 0 Striche hat.",
        ItemRolltypeChangeFailed = "Das ändern des Strichs von %s zu %s ist fehlgeschlagen, da %s 0 Striche auf %s hat.",
        ItemRolltypeChangeFailed2 = "Das ändern des Strichs von %s zu %s ist fehlgeschlagen, da %s nicht mehr in der Datenbank existiert.",
        RaidMemNotInDB = "Raidmember %s does not exist in DB.",
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
        RollReassigned = "Edited",
        Winner = "%s hat potentiell %s gewonnen!",
    },
    TallyMarkTypes = {
        Main = "Main",
        Sec = "Sec",
        Token = "Token",
        TokenSec = "TokenSec",
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
        SetAssist = "Zu StriLi-Assist ernennen",
        UnsetAssist = "StriLi-Assist Status entfernen",
        Remove = "Entfernen",
        Print = "Alle Würfe zeigen",
        YourNotMaster = "You are not the StriLi master.",
        PlayerChange = "Anderem Spieler zuweisen",
        RolltypeChange = "Strich ändern",
    },
    Confirm = {
        RaidLeftResetData = "Du hast den Raid verlassen. Möchtest du alle Daten zurücksetzen?",
        NewRaidResetData = "Du hast eine neue Raid-Gruppe betreten. Möchtest du alle Daten zurücksetzen?",
        ResetDataConfirm = "Bist du sicher, das du alle Daten zurücksetzen willst?",
        SyncDataConfirm = "Du bist StriLi-Master. Bist du sicher das du die Daten Synchronisieren möchtest? Deine Daten werden überschrieben.",
        ReregisterRequest = "Gib den Spec an auf den Umgemeldet wird",
        AreYouSureTo = "Bist du sicher, dass du",
        SetMaster = "zum Master ernennen möchtest?",
        SetAssist = "zum StriLi-Assist ernennen möchtest?",
        UnsetAssist = "den StriLi-Assist Status entfernen möchtest?",
        Remove = "entfernen möchtest?",
        Combine1 = "mit",
        Combine2 = "zusammenlegen möchtest?",
        Combine3 = "wird behalten)",
        ItemAssign = "das Item neu zuweisen möchtest?",
        ItemRemove = "Bist du Sicher das du das Item entfernen möchtest?",
        ItemRolltypeChange = "den Strich ändern möchtest?",
    },
    Labels = {
        Status = "StriLi Status",
        Name = "Name",
        Reregister = "U",
        Main = "Main",
        Sec = "Sec",
        Token = "Token",
        TokenSec = "TokenSec",
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
        ButtonSave = "Save",
        ButtonItemHistory = "ItemHistory",
        NewStriLiVersion = "Eine neue Version von StriLi ist verfügbar unter:",
        CopyMacro = "Copy and create a macro from it.\n Replace the <> and the text in it with your desired time.",
        ButtonOk = "Ok",
        LootRules = "Loot Rules",
    },
    Options = {
        AutoPromote = "Auto promote StriLi master to raid assist.",
        TokenSec = "Token sec list.",
        IgnoreGroup = "Ignore group",
    },
    Tooltip = {
        rightClickText = "|cffff0000RightClick|r Open/Close ItemHistory",
        leftClickText = "|cff1eff00LeftClick|r Open/Close StriLi",
        dragClickText = "|cffccccccLeftClick + Drag|r Move Minimap-Button",
    },
};

function StriLi.InitLang()

    local lang = GetLocale();

    if lang == "deDE" then
        StriLi.Lang = StriLi_Stub_deDE();
    elseif lang == "enGB" or lang == "enUS" then
        StriLi.Lang = StriLi_Stub_enGB();
    elseif lang == "esES" then
        StriLi.Lang = StriLi_Stub_esES();
    else
        --error("WTF?!");
    end

end