-- Do not operate outside of the server during multiplayer
-- if not isServer() then return end

-- Function initialization
S4Economy = {}
local function getCardCreditLimit()
    local maxNegative = 1000
    if SandboxVars and SandboxVars.S4SandBox and SandboxVars.S4SandBox.MaxNegativeBalance then
        maxNegative = SandboxVars.S4SandBox.MaxNegativeBalance
    end
    if maxNegative < 0 then
        maxNegative = 0
    end
    return -maxNegative
end

local function canCardSpend(account, amount)
    if not account or not amount or amount <= 0 then return false end
    return (account.Money - amount) >= getCardCreditLimit()
end

-- Create card data
function S4Economy.CreateCardData(player, args)
    local CardModData = ModData.get("S4_CardData")
    local CardNum = args[1]
    local UserName = player:getUsername()
    local Account = ModData.get("S4_CardData")[CardNum]
    local LogAccount = ModData.get("S4_CardLog")[CardNum]
    if Account or LogAccount then print("TestCard Data Funk") return end
    ModData.get("S4_CardData")[CardNum] = {
        Master = UserName,
        Password = args[2],
        Money = args[3],
    }
    local LogTime = args[4]
    local LogTimeMin = S4_Utils.getLogTimeMin(LogTime)
    ModData.get("S4_CardLog")[CardNum] = {}
    ModData.get("S4_CardLog")[CardNum][LogTime] = {
        Type = "Deposit",
        Money = args[3],
        Sender = "ZomBank",
        Receiver = UserName,
        DisplayTime = LogTimeMin,
    }
    ModData.transmit("S4_CardData")
    ModData.transmit("S4_CardLog")
end

-- Card password settings
function S4Economy.setPassword(player, args)
    local CardNum = args[1]
    local Account = ModData.get("S4_CardData")[CardNum]
    if not Account then return end
    Account.Password = args[2]
    ModData.transmit("S4_CardData")
end

-- Add card balance
function S4Economy.AddMoney(player, args)
    local CardNum = args[1]
    local Account = ModData.get("S4_CardData")[CardNum]
    if not Account then return end
    Account.Money = Account.Money + args[2]
    ModData.transmit("S4_CardData")
end

-- Decrease card balance
function S4Economy.RemoveMoney(player, args)
    local CardNum = args[1]
    local Account = ModData.get("S4_CardData")[CardNum]
    if not Account then return end
    if not canCardSpend(Account, args[2]) then return end
    Account.Money = Account.Money - args[2]
    ModData.transmit("S4_CardData")
end

-- card transfer
function S4Economy.TransferCard(player, args)
    local SenderCardNum = args[1]
    local ReceiverCardNum = args[2]
    local MoneyValue = args[3]
    -- local SenderName = player:getUsername()
    -- local ReceiverName = args[4]
    local TransferTime = args[4]

    local SenderAccount = ModData.get("S4_CardData")[SenderCardNum]
    local ReceiverAccount = ModData.get("S4_CardData")[ReceiverCardNum]
    if not SenderAccount or not ReceiverAccount then return end
    if not canCardSpend(SenderAccount, MoneyValue) then return end
    SenderAccount.Money = SenderAccount.Money - MoneyValue
    ReceiverAccount.Money = ReceiverAccount.Money + MoneyValue
    ModData.transmit("S4_CardData")

    local LogTable = {
        TransferTime,
        SenderCardNum,
        SenderAccount.Master,
        ReceiverCardNum,
        ReceiverAccount.Master,
        MoneyValue,
    }
    S4Economy.AddTransferLog_Card(LogTable)
end

-- cash transfer
function S4Economy.TransferCash(player, args)
    local ReceiverCardNum = args[1]
    local MoneyValue = args[2]
    local SenderName = player:getUsername()
    local TransferTime = args[3]

    local ReceiverAccount = ModData.get("S4_CardData")[ReceiverCardNum]
    if not ReceiverAccount then return end
    ReceiverAccount.Money = ReceiverAccount.Money + MoneyValue
    ModData.transmit("S4_CardData")

    local LogTable = {
        TransferTime,
        "Deposit",
        SenderName,
        ReceiverCardNum,
        ReceiverAccount.Master,
        MoneyValue,
    }
    S4Economy.AddTransferLog_Cash(LogTable)
end

-- Card log processing (Clar)
function S4Economy.AddCardLog(player, args)
    local CardNum = args[1] -- card number
    local LogTime = args[2] -- save time
    local LogType = args[3] -- transaction type
    local LogMoney = args[4] -- transaction amount
    local LogSender = args[5] -- Sender/User
    local LogReceiver = args[6] -- Recipient/Where to use
    local LogTimeMin = S4_Utils.getLogTimeMin(LogTime)

    local Account = ModData.get("S4_CardLog")[CardNum]
    if not Account then return end

    Account[LogTime] = {
        Type = LogType,
        Money = LogMoney,
        Sender = LogSender,
        Receiver = LogReceiver,
        DisplayTime = LogTimeMin,
    }

    ModData.transmit("S4_CardLog")
end

-- Card transfer log processing (server)
function S4Economy.AddTransferLog_Card(args)
    local LogTime = args[1]

    local SenderCardNum = args[2]
    local SenderName = args[3]
    local ReceiverCardNum = args[4]
    local Receivername = args[5]
    local MoneyValue = args[6]
    local LogTimeMin = S4_Utils.getLogTimeMin(LogTime)

    local SenderAccount = ModData.get("S4_CardLog")[SenderCardNum]
    local ReceiverAccount = ModData.get("S4_CardLog")[ReceiverCardNum]
    if not SenderAccount or not ReceiverAccount then return end
    SenderAccount[LogTime] = {
        Type = "Withdraw",
        Money = MoneyValue,
        Sender = SenderName,
        Receiver = Receivername,
        DisplayTime = LogTimeMin,
    }
    ReceiverAccount[LogTime] = {
        Type = "Deposit",
        Money = MoneyValue,
        Sender = SenderName,
        Receiver = Receivername,
        DisplayTime = LogTimeMin,
    }
    ModData.transmit("S4_CardLog")
end

-- Cash remittance log processing (server)
function S4Economy.AddTransferLog_Cash(args)
    local LogTime = args[1]
    local LogType = args[2]
    local SenderName = args[3]
    local ReceiverCardNum = args[4]
    local Receivername = args[5]
    local MoneyValue = args[6]
    local LogTimeMin = S4_Utils.getLogTimeMin(LogTime)

    local ReceiverAccount = ModData.get("S4_CardLog")[ReceiverCardNum]
    if not ReceiverAccount then return end
    ReceiverAccount[LogTime] = {
        Type = LogType,
        Money = MoneyValue,
        Sender = SenderName,
        Receiver = Receivername,
        DisplayTime = LogTimeMin,
    }
    ModData.transmit("S4_CardLog")
end

-- Delete card data
function S4Economy.RemoveCardData(player, args)
    local UserName = player:getUsername()
    local PlayerModData = ModData.get("S4_PlayerData")[UserName]
    local CardModData = ModData.get("S4_CardData")[args[1]]
    local CardLogModData = ModData.get("S4_CardLog")[args[1]]
    if not PlayerModData or not CardModData or not CardLogModData then return end
    if PlayerModData.MainCard == args[1] then PlayerModData.MainCard = false end
    CardModData.Master = false
    CardModData.Password = "Remover: " .. UserName .. "/Money: " .. CardModData.Money
    CardModData.Money = 0
    ModData.get("S4_CardLog")[args[1]] = {}
    ModData.transmit("S4_PlayerData")
    ModData.transmit("S4_CardData")
    ModData.transmit("S4_CardLog")
end

-- Related to new card issuance (card data transfer)
function S4Economy.ReplacementCardData(player, args)
    local UserName = player:getUsername()
    local PlayerModData = ModData.get("S4_PlayerData")
    local PlayerShopModData = ModData.get("S4_PlayerShopData")
    local CardModData = ModData.get("S4_CardData")
    local CardLogModData = ModData.get("S4_CardLog")
    if not PlayerModData[UserName] or not PlayerShopModData[UserName] or not CardModData[args[1]] or not CardLogModData[args[1]] then return end
    if CardModData[args[2]] or CardLogModData[args[2]] then return end 
    if PlayerModData[UserName].MainCard == args[1] then PlayerModData[UserName].MainCard = args[2] end
    
    local Commission = math.floor(CardModData[args[1]].Money * 0.1)
    CardModData[args[2]] = {
        Master = CardModData[args[1]].Master,
        Password = CardModData[args[1]].Password,
        Money = CardModData[args[1]].Money - Commission,
    }
    CardLogModData[args[2]] = CardLogModData[args[1]]
    CardLogModData[args[2]][args[3]] = {
        Type = "Withdraw",
        Money = Commission,
        Sender = UserName,
        Receiver = "ZomBank",
        DisplayTime = args[4],
    }
    PlayerShopModData[UserName].Delivery[args[5]] = {}
    PlayerShopModData[UserName].Delivery[args[5]].XYZCode = args[6]
    PlayerShopModData[UserName].Delivery[args[5]].List = {}
    PlayerShopModData[UserName].Delivery[args[5]].List["Base.CreditCard"] = 1
    PlayerShopModData[UserName].Delivery[args[5]].BankCard = args[2]

    CardModData[args[1]].Master = false
    CardModData[args[1]].Password = "Remover: " .. UserName .."/NewCard: " .. args[2]
    CardModData[args[1]].Money = 0
    ModData.get("S4_CardLog")[args[1]] = {}
    ModData.transmit("S4_PlayerData")
    ModData.transmit("S4_PlayerShopData")
    ModData.transmit("S4_CardData")
    ModData.transmit("S4_CardLog")
end

-- Loan System
function S4Economy.RequestLoan(player, args)
    local UserName = player:getUsername()
    local CardNum = args[1]
    local Lender = args[2]
    local Amount = args[3]
    local InterestRate = args[4]
    local TotalToPay = args[5]
    local DeadlineDays = args[6]
    local Timestamp = args[7]
    local DisplayTime = args[8]

    local CardModData = ModData.get("S4_CardData")
    local LoanModData = ModData.get("S4_LoanData")
    local CardLogModData = ModData.get("S4_CardLog")

    if not CardModData[CardNum] then return end

    -- Initialize player loan table if not exists
    if not LoanModData[UserName] then
        LoanModData[UserName] = {}
    end

    -- Add Money to Card
    CardModData[CardNum].Money = CardModData[CardNum].Money + Amount

    -- Record Loan
    table.insert(LoanModData[UserName], {
        Lender = Lender,
        Amount = Amount,
        InterestRate = InterestRate,
        TotalToPay = TotalToPay,
        Deadline = DeadlineDays,
        Timestamp = Timestamp,
        DisplayTime = DisplayTime,
        StartDay = getGameTime():getDay(), -- Store the game day for deadline tracking
        CardNum = CardNum,
        Repaid = 0,
        Status = "Active"
    })

    -- Add to Card Log
    if not CardLogModData[CardNum] then
        CardLogModData[CardNum] = {}
    end
    CardLogModData[CardNum][Timestamp] = {
        Type = "Loan",
        Money = Amount,
        Sender = Lender,
        Receiver = UserName,
        DisplayTime = DisplayTime,
    }

    ModData.transmit("S4_CardData")
    ModData.transmit("S4_LoanData")
    ModData.transmit("S4_CardLog")
end

function S4Economy.RepayLoan(player, args)
    local UserName = player:getUsername()
    local CardNum = args[1]
    local LoanIndex = args[2]
    local RepayAmount = args[3]
    local Timestamp = args[4]
    local DisplayTime = args[5]
    local IsDebug = args[6] -- New debug flag

    local CardModData = ModData.get("S4_CardData")
    local LoanModData = ModData.get("S4_LoanData")
    local CardLogModData = ModData.get("S4_CardLog")

    if not LoanModData[UserName] or not LoanModData[UserName][LoanIndex] then return end

    local loan = LoanModData[UserName][LoanIndex]
    
    -- Normal logic for non-debug repayment
    if not IsDebug then
        if not CardModData[CardNum] then return end
        
        -- Check if card has enough money
        if CardModData[CardNum].Money < RepayAmount then return end

        -- Deduct money
        CardModData[CardNum].Money = CardModData[CardNum].Money - RepayAmount
    end

    -- Update Loan Data (Always runs)
    loan.Repaid = (loan.Repaid or 0) + RepayAmount
    if loan.Repaid >= loan.TotalToPay then
        loan.Status = "Repaid"
    end

    -- Add to Log (Always runs, but CardModData transmit only if not debug)
    if not CardLogModData[CardNum] then
        CardLogModData[CardNum] = {}
    end
    CardLogModData[CardNum][Timestamp] = {
        Type = "Repay",
        Money = RepayAmount,
        Sender = UserName,
        Receiver = loan.Lender,
        DisplayTime = DisplayTime,
    }

    ModData.transmit("S4_CardData")
    ModData.transmit("S4_LoanData")
    ModData.transmit("S4_CardLog")
end
