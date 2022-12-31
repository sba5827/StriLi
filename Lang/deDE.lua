function StriLi_Stub_deDE() return {
    ErrorMsg = {
        ExpectNumAsItemID = "Es wurde eine Zahl als ItemID erwartet!",
        ExpectNumAsTime = "Es Wurde eine Zahl al time erwartet!",
        CombineMembers1 = "Zusammenlegen von",
        CombineMembers2 = "und",
        CombineMembers3 = "ist fehlgeschlagen während die Nachricht DataChanged empfangen wurde.",
        MasterInitFail = "Master kann nicht initialisiert werden",
        Argument = "Argument",
        IsNotString = "ist kein String-Typ.",
        IsNotItemLink = "ist kein Item-Link.",
        IsNotNumber = "ist kein Zahlen-Type.",
        RemoveOnlineRaidmember = "Es können keine Raidmember die Online sind aus StriLi entfernt werden.",
        ObserverImplement = "Observer muss OnValueChanged implementieren",
        SetMasterNotPossible = "kann nicht zum Master ernannt werden.",
        RankToLow = "Rang zu niedrig",
        PlayerNotInRaid = "befindet sich nicht in der Raidgruppe.",
        PossibleCauses = "Mögliche Ursachen",
        Cause1 = "ist Ausgeloggt.",
        Cause2 = "hat einen Disconect.",
        Cause3 = "Du hast einen Disconect.",
        Cause4 = "hat StriLi nicht.",
        Cause5 = "hat eine stark veraltete Version von StriLi.",
        ItemReassignFailed = "Das Zuweisen des Items an %s ist fehlgeschlagen. Die Striche von %s waren 0.",
        ItemRemoveFailed = "Das entfernen des Items ist fehlgeschlagen, da %s 0 Striche hat.",
        ItemRolltypeChangeFailed = "Das ändern des Strichs von %s zu %s ist fehlgeschlagen, da %s 0 Striche auf %s hat.",
        ItemRolltypeChangeFailed2 = "Das ändern des Strichs von %s zu %s ist fehlgeschlagen, da %s nicht mehr in der Datenbank existiert.",
    },
    Rolls = {
        StartRoll1 = "Es wird um das Item ",
        StartRoll2 = " gewürfelt. Du hast ",
        StartRoll3 = " Sekunden Zeit.",
        TallyMarks = "Striche",
        Fails = "Fehler",
        Roll = "Wurf",
        NoRollToCancel = "Es wird um kein Item gewürfelt.",
        RollCanceled = "Würfeln abgebrochen.",
        RollAlreadyInProgress = "Es wird schon um ein Item gewürfelt. Um den Vorgang zu unterbrechen tippe",
        RollReassigned = "Bearbeitet",
    },
    TallyMarkTypes = {
        Main = "Main",
        Sec = "Sec",
        Token = "Token",
        Fail = "Fehler",
    },
    Name = "Name",
    version = "Version",
    loaded = "geladen",
    Commands = {
        InvalideNotInRaid = "Befehl nicht gültig. Du befindest dich nicht in einem Raid.",
        AvailableCommands = "Verfügbare Befehle",
        TimeInSec = "Zeit in s",
        NoPermRankToLow = "Keine Berechtigung. Dein Rang ist zu niedrig.",
        FirstArgNum = "Erstes Argument muss eine Zahl sein.",
        PlayersGotLoot = "Spieler die kein Item bekommen haben",
        CombineMembers = "Zusammenlegen mit",
        Reregister = "Ummelden",
        SetMaster = "Zu Master ernennen",
        Remove = "Entfernen",
        YourNotMaster = "Du bist nicht der StriLi master.",
        PlayerChange = "Anderem Spieler zuweisen",
        RolltypeChange = "Strich ändern",
    },
    Confirm = {
        RaidLeftResetData = "Du hast den Raid verlassen. Möchtest du alle Daten zurücksetzen?",
        NewRaidResetData = "Du hast eine neue Raid-Gruppe betreten. Möchtest du alle Daten zurücksetzen?",
        ResetDataConfirm = "Bist du sicher, das du alle Daten zurücksetzen willst?",
        ReregisterRequest = "Gib den Spec an auf den Umgemeldet wird",
        SyncDataConfirm = "Du bist StriLi-Master. Bist du sicher das du die Daten Synchronisieren möchtest? Deine Daten werden überschrieben.",
        AreYouSureTo = "Bist du sicher, dass du",
        SetMaster = "zum Master ernennen möchtest?",
        Remove = "entfernen möchtest?",
        Combine1 = "mit",
        Combine2 = "zusammenlegen möchtest?",
        Combine3 = "wird behalten)",
        ItemAssign = "das Item neu zuweisen möchtest?",
        ItemRemove = "Bist du Sicher das du das Item entfernen möchtest?",
        ItemRolltypeChange = "den Strich ändern möchtest?",
    },
    Labels = {
        Name = "Name",
        Reregister = "U",
        Main = "Main",
        Sec = "Sec",
        Token = "Token",
        Fail = "Fehler",
        Lock = "Sperren",
        Unlock = "Entsperren",
        Ascending = "'",
        Descending = ",",
        Class = "Klasse",
    },
    XML = {
        ButtonYes = "Ja",
        ButtonCancel = "Abbrechen",
        ButtonReset = "Zurücksetzen",
        ButtonSync = "Synchronisieren",
        ButtonLock = "Sperren",
        ButtonSort = "Sortieren",
        ButtonSave = "Speichern",
        ButtonItemHistory = "Item Verlauf",
        NewStriLiVersion = "Eine neue Version von StriLi ist verfügbar unter:",
        CopyMacro = "Kopiere und erstelle daraus ein Makro.\n Ersetze dabei das <> und den darin enthaltenen Text durch die gewünschte Zeit.",
        ButtonOk = "Ok",
        LootRules = "Loot Regeln",
    },
};
end