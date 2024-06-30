local UserInputService = game:GetService("UserInputService")

local TypeTester = {}
TypeTester.__index = TypeTester

function TypeTester.new(UI)
    local self = setmetatable({}, TypeTester)

    self.wordsPool = {"apple", "run", "banana", "happy", "cherry", "jump", "date", "blue", "elderberry", "swim", "fig", "bright", "grape", "dance", "honeydew", "sad", "kiwi", "laugh", "lemon", "green", "mango", "build", "nectarine", "quick", "orange", "sing", "papaya", "red", "quince", "write", "raspberry", "slow", "strawberry", "paint", "tangerine", "angry", "ugli", "climb", "vanilla", "brave","watermelon", "think", "xigua", "strong", "yam", "fly", "zucchini", "smart", "avocado", "read" }
	self.inSession = false

    self.timerAmount = 15
    self.wordsAmount = 30
    
    self.currentWords = {} 
    self.currentLetters = {}

    self.currentIndex = 0
    self.wrongIndexes = {}

    self.fullString = ""
    self.currentWordsLength = 0

    self.UI = UI

    --// <font color=""></font>
    return self
end


function TypeTester:SetTimer(n : number)
    self.timerAmount = n
end

function TypeTester:SetWordsAmount(n : number)
    self.wordsAmount = n
end

function TypeTester:GenerateWords()
    for i = 1, self.wordsAmount do
        local randomWord = self.wordsPool[math.random(#self.wordsPool)]
        
        table.insert(self.currentWords, randomWord)
        self.currentWordsLength += string.len(randomWord)
        self.fullString = self.fullString..(i == 1 and "" or " ")..randomWord  

        for _, letter in randomWord:split("") do
            table.insert(self.currentLetters, letter)
        end
        table.insert(self.currentLetters, " ")
    end
end

function TypeTester:BeginTimer()
    self.timer = task.spawn(function()
        for i = 1, self.timerAmount do
            task.wait(1)
        end
        
        self:EndSession();
        self.timer = nil;
    end)

end

function TypeTester:StartSession()
    self.inSession = true
    self:BeginTimer();
end

function TypeTester:EndSession()
    self.inSession = false
end

function TypeTester:ApplyText(t : string)
    local textLabel = self.UI.Background.Container.TextArea
    textLabel.Text = t
end

function TypeTester:GetColoredString()
    local currentWords = ""

    for i = 1, self.currentIndex do
        local letter = self.currentLetters[i]

        if table.find(self.wrongIndexes, i) then
           currentWords = currentWords..'<font color="#FF0000">'..letter..'</font>'
        else
            currentWords = currentWords..'<font color="#FFFFFF">'..letter..'</font>'
        end
    end

    for i = self.currentIndex + 1, #self.currentLetters do
        local letter = self.currentLetters[i]
        currentWords = currentWords..'<font color="#797979">'..letter..'</font>'
    end

    return currentWords
end

function TypeTester:ProcessKey(key : string)
    local nextIndex = self.currentIndex + 1 
    local isCorrect = self.currentLetters[nextIndex] == key

    if not isCorrect then
        table.insert(self.wrongIndexes,  nextIndex)
    end

    self.currentIndex += 1

    local text = self:GetColoredString()
    self:ApplyText(text);
end

function TypeTester:Init()
    self:GenerateWords()
    self:ApplyText(self.fullString);

    UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Keyboard then
			if not self.inSession then
                self:StartSession();
            end

            local key = UserInputService:GetStringForKeyCode(input.KeyCode)
            
            if input.KeyCode == Enum.KeyCode.Backspace then
                key = "backspace"
            end

            if key == " " and input.KeyCode == Enum.KeyCode.Space then
                print('invalid key')
                return
            end

            self:ProcessKey(key:lower());
		end
	end)
end

function TypeTester:ShowResults()
    
end

function TypeTester:Destroy()
    
end

return TypeTester