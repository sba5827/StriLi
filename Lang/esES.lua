function StriLi_Stub_esES() return {
    ErrorMsg = {
        ExpectNumAsItemID = "¡Se esperaba un número como ItemID!",
        ExpectNumAsTime = "¡Se esperaba un número al time!",
        CombineMembers1 = "La fusión de",
        CombineMembers2 = "y",
        CombineMembers3 = "ha fallado al recibir el mensaje DataChanged.",
        MasterInitFail = "No se puede inicializar el maestro",
        Argument = "Argumento",
        IsNotString = "no es un tipo de cadena.",
        IsNotItemLink = "no es un enlace de artículo.",
        IsNotNumber = "no es de tipo numérico.",
        RemoveOnlineRaidmember = "No se puede expulsar de StriLi a ningún miembro de la redada que esté conectado.",
        ObserverImplement = "El Observer debe implementar OnValueChanged",
        SetMasterNotPossible = "no puede ser nombrado Maestro.",
        RankToLow = "Rango demasiado bajo",
        PlayerNotInRaid = "no está en el grupo de asalto.",
        PossibleCauses = "Posibles causas",
        Cause1 = "está desconectado.",
        Cause2 = "tiene una disconectada.",
        Cause3 = "Tienes una disconección.",
        Cause4 = "no tiene StriLi.",
        Cause5 = "tiene una versión muy anticuada de StriLi.",
        ItemReassignFailed = "La asignación del elemento a %s ha fallado. Los guiones de %s eran 0.",
        ItemRemoveFailed = "La eliminación del elemento ha fallado porque %s tiene 0 guiones.",
        ItemRolltypeChangeFailed = "El cambio de trazo de %s a %s falló porque %s tiene 0 trazos en %s.",
        ItemRolltypeChangeFailed2 = "El cambio del trazo de %s a %s ha fallado porque %s ya no existe en la base de datos.",
    },
    Rolls = {
        StartRoll1 = "Se tiran los dados por el objeto ",
        StartRoll2 = " Tienes  ",
        StartRoll3 = " segundos.",
        TallyMarks = "Trazos",
        Fails = "Error",
        Roll = "Camada",
        NoRollToCancel = "No se tiran dados por ningún objeto.",
        RollCanceled = "Dados cancelados.",
        RollAlreadyInProgress = "Ya se están tirando los dados para un artículo. Para interrumpir el proceso, escriba",
        RollReassigned = "Editado",
    },
    TallyMarkTypes = {
        Main = "Principal",
        Sec = "Segundo",
        Token = "Token",
        Fail = "Error",
    },
    Name = "Nombre",
    version = "Versión",
    loaded = "cargado",
    Commands = {
        InvalideNotInRaid = "Orden no válida. No estás en una redada.",
        AvailableCommands = "Comandos disponibles",
        TimeInSec = "Tiempo en s",
        NoPermRankToLow = "Sin autorización. Tu rango es demasiado bajo.",
        FirstArgNum = "El primer argumento debe ser un número.",
        PlayersGotLoot = "Jugadores que no han recibido un artículo",
        CombineMembers = "Fusionar con",
        Reregister = "Vuelva a registrar",
        SetMaster = "Nombrar Maestro",
        Remove = "Eliminar",
        YourNotMaster = "No eres el maestro de StriLi.",
        PlayerChange = "Asignar a otro jugador",
        RolltypeChange = "Cambiar el ictus",
    },
    Confirm = {
        RaidLeftResetData = "Has abandonado la redada. ¿Quieres restablecer todos los datos?",
        NewRaidResetData = "Has entrado en un nuevo grupo de asalto. ¿Quieres restablecer todos los datos?",
        ResetDataConfirm = "¿Estás seguro de que quieres restablecer todos los datos?",
        ReregisterRequest = "Especifique la especificación a la que desea convertir",
        SyncDataConfirm = "Eres el Maestro StriLi. ¿Estás seguro de que quieres sincronizar los datos? Tus datos se sobrescribirán.",
        AreYouSureTo = "¿Estás seguro de que quieres",
        SetMaster = "para convertirse en Maestro?",
        Remove = "¿quiere eliminar?",
        Combine1 = "quiere fusionarse con",
        Combine2 = "?",
        Combine3 = "se mantiene)",
        ItemAssign = "como nuevo propietario de este artículo?",
        ItemRemove = "¿Estás seguro de que quieres eliminar el artículo?",
        ItemRolltypeChange = "cambiar la carrera?",
    },
    Labels = {
        Name = "Nombre",
        Reregister = "R",
        Main = "Principal",
        Sec = "Segundo",
        Token = "Token",
        Fail = "Error",
        Lock = "Bloquear",
        Unlock = "Desbloquear",
        Ascending = "'",
        Descending = ",",
        Class = "Clase",
    },
    XML = {
        ButtonYes = "Sí",
        ButtonCancel = "Cancelar",
        ButtonReset = "Restablecer",
        ButtonSync = "Sincronice",
        ButtonLock = "Bloquear",
        ButtonSort = "Ordenar",
        ButtonSave = "Guarde",
        ButtonItemHistory = "Historia Item",
        NewStriLiVersion = "Una nueva versión de StriLi está disponible en:",
        CopyMacro = "Copia y crea una macro a partir de ella.\n Sustituye el <> y el texto que contiene por la hora que desees.",
        ButtonOk = "Ok",
        LootRules = "Normas de botín",
    },
};
end