local addOn, Language = ...
local Keyboard = ConsolePortKeyboard
---------------------------------------------------------------
-- Local resources
---------------------------------------------------------------
local escapes = {
   "|c%x%x%x%x%x%x%x%x",
   "[0-9]+",
   "\124T.-\124t",
   "|T.-|t",
   "|H.-|h",
   "|n",
   "|r",
   "/[%w]+",
   "{Atlas|.-}",
}

local function Unescape(str)
   if str then
      for _, esc in pairs(escapes) do
         str = str:gsub(esc, " ")
      end
      return str
   end
end

---------------------------------------------------------------
-- Dictionary operations
---------------------------------------------------------------
function Keyboard:GenerateDictionary()
   -- generates a localized game-oriented dictionary (5000+ words on enUS clients)
   -- scan the global environment for strings
   local genv = getfenv(0)
   local dictionary = {}
   for index, object in pairs(genv) do
      if type(object) == "string" then
         -- remove escape sequences
         object = Unescape(object)
         -- scan each string for individual words
         for word in object:gmatch("[%a][%w']*[%w]+") do
            word = strlower(word)
            if not dictionary[word] then
               dictionary[word] = 1
            else
               dictionary[word] = dictionary[word] + 1
            end
         end
      end
   end
   return dictionary
end

function Keyboard:UpdateDictionary()
   -- store new words from the current input and update frequency of others
   local dictionary = self.Dictionary
   for word in self.Mime:GetText():gmatch("[%a][%w']*[%w]+") do
      word = strlower(word)
      if not dictionary[word] then
         dictionary[word] = 1
      else
         dictionary[word] = dictionary[word] + 1
      end
   end
end

function Keyboard:NormalizeDictionary()
   -- normalize the word frequency values on login to avoid frequency bloat over time
   -- using this approach, the frequencies will stay relevant to eachother instead of growing exponentially
   -- example: enUS default frequency for "you" is ~2300, but only ~170 after normalizing
   local dictionary = self.Dictionary

   local weight, ceiling = 0, 0
   local weights = {}
   local newDictionary = {}

   -- find the highest frequency
   for word, freq in pairs(dictionary) do
      if freq > ceiling then
         ceiling = freq
      end
   end

   -- generate empty weight tables (expensive when dictionary has never been normalized)
   for i=1, ceiling do
      weights[i] = {}
   end

   -- store words in their respective weight table
   for word, freq in pairs(dictionary) do
      tinsert(weights[freq], word)
   end

   -- get rid of empty weight tables
   for index, words in pairs(weights) do
      if next(words) == nil then
         weights[index] = nil
      end
   end

   -- generate a normalized dictionary by incrementally counting weight classes
   for _, words in pairs(weights) do
      weight = weight + 1
      for _, word in pairs(words) do
         newDictionary[word] = weight
      end
   end

   dictionary = nil

   ConsolePortKeyboardDictionary = newDictionary
   self.Dictionary = newDictionary
end