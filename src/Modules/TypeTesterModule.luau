local UserInputService = game:GetService("UserInputService")

local TypeTester = {}
TypeTester.__index = TypeTester

function TypeTester.new(UI)
    local self = setmetatable({}, TypeTester)

    self.wordsPool = {"apple", "run", "banana", "happy", "cherry", "jump", "date", "blue", "elderberry", "swim", "fig", "bright", "grape", "dance", "honeydew", "sad", "kiwi", "laugh", "lemon", "green", "mango", "build", "nectarine", "quick", "orange", "sing", "papaya", "red", "quince", "write", "raspberry", "slow", "strawberry", "paint", "tangerine", "angry", "ugli", "climb", "vanilla", "brave","watermelon", "think", "xigua", "strong", "yam", "fly", "zucchini", "smart", "avocado", "read" }
	self.inSession = false

    self.timerAmount = 15
    self.wordsAmount = 30
    
    self._words = {}
    self._wrongKeys = {}

    self._currentWord = nil
    self._currentLetters = {}
    self._writtenLetters = {}
    self._coloredWords = {}

    self._currentWordIndex = 1
    self._currentLetterIndex = 0

    self._fullString = ""
    self._wordsLength = 0

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

function TypeTester:SplitCurrentWord()
    self._currentLetters = {}

    for _, letter in self._currentWord:split("") do
        table.insert(self._currentLetters, letter)
    end
end

function TypeTester:GenerateWords()
    for index = 1, self.wordsAmount do
        local randomWord = self.wordsPool[math.random(#self.wordsPool)]
        table.insert(self._words, randomWord)

        if index == 1 then
            self._fullString = self._fullString..randomWord
            self._currentWord = randomWord
            self:SplitCurrentWord();
        else
            self._fullString = self._fullString.." "..randomWord
        end

        self._wordsLength += randomWord:len();
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
    local function _colorCurrentWord()
        local _string = ""

        for index, letter in ipairs(self._currentLetters) do
            if #self._writtenLetters < index then
                _string = _string..'<font color="#797979">'..letter..'</font>'
                continue
            end

            if table.find(self._wrongKeys, index) then
                _string = _string..'<font color="#FF0000">'..letter..'</font>' --// mark red
             else
                _string = _string..'<font color="#FFFFFF">'..letter..'</font>' --// mark white
             end
        end

        if #self._writtenLetters > #self._currentLetters then
            for i = #self._currentLetters + 1, #self._writtenLetters do
                local letter = self._writtenLetters[i]
                _string = _string..'<font color="#FF0000">'..letter..'</font>' --// mark red
            end
        end

        return _string
    end

    print(self._writtenLetters, self._wrongKeys)
    self._coloredWords[self._currentWordIndex] = _colorCurrentWord();
    local finalString = ""

    for _, word in ipairs(self._coloredWords) do
        finalString = finalString.." "..word
    end
    
    for i = self._currentWordIndex + 1, #self._words do
        local letter = self._words[i]
        finalString = finalString.." "..'<font color="#797979">'..letter..'</font>'
    end

    return finalString
end

function TypeTester:ProcessKey(key : string)
    if key ~= " " and key ~= "backspace" then
        self._currentLetterIndex += 1
        table.insert(self._writtenLetters, key)
    
        if self._currentLetters[self._currentLetterIndex] ~= key then
            print("isn't key", self._currentLetters[self._currentLetterIndex],self._currentLetterIndex, key)
            table.insert(self._wrongKeys, self._currentLetterIndex);
        end
    end

    if key == "backspace" then
        self._currentLetterIndex = (self._currentLetterIndex > 0) and self._currentLetterIndex-1 or 0

        if table.find(self._wrongKeys, #self._writtenLetters) then
            table.remove(self._wrongKeys, #self._writtenLetters)
        end

        table.remove(self._writtenLetters, #self._writtenLetters)
    end

    if key == " " then
        --// spacebar
        self._currentLetterIndex = 0
        self._currentWordIndex += 1
        self._currentWord = self._words[self._currentWordIndex]

        self._writtenLetters = {}
        self._wrongKeys = {}
        self:SplitCurrentWord();
    end

    local text = self:GetColoredString()
    self:ApplyText(text);
end

function TypeTester:Init()
    self:GenerateWords()
    self:ApplyText(self._fullString);

    self.connection = UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Keyboard then
			if not self.inSession then
                self:StartSession();
            end

            local key = UserInputService:GetStringForKeyCode(input.KeyCode):lower();

            if input.KeyCode == Enum.KeyCode.Backspace then
                key = "backspace"
            end

            if key == " " and input.KeyCode ~= Enum.KeyCode.Space then
                return
            end

            self:ProcessKey(key);
		end
	end)
end

function TypeTester:ShowResults()
    
end

function TypeTester:Destroy()
    
end

return TypeTester