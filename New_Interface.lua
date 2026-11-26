-- HORIZON UI 2.0 | Standalone visual preview
-- No gameplay functions, remote requests, or modifications to the original HORIZON.
-- Uses Roblox UI objects only. Intended for client-side execution.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
if not player then return end

local parentGui
local ok, core = pcall(function() return game:GetService("CoreGui") end)
if ok and core then
    local success = pcall(function()
        local probe = Instance.new("Folder")
        probe.Name = "HorizonUiProbe"
        probe.Parent = core
        probe:Destroy()
    end)
    if success then parentGui = core end
end
if not parentGui then
    parentGui = player:WaitForChild("PlayerGui")
end

local old = parentGui:FindFirstChild("HORIZON_UI_2_0_PREVIEW")
if old then old:Destroy() end

local function new(class, props, parent)
    local object = Instance.new(class)
    for k,v in pairs(props or {}) do object[k] = v end
    object.Parent = parent
    return object
end
local function corner(parent, radius)
    return new("UICorner", {CornerRadius = UDim.new(0, radius)}, parent)
end
local function stroke(parent, color, transparency, thickness)
    return new("UIStroke", {Color=color, Transparency=transparency, Thickness=thickness}, parent)
end
local C = {
    outer=Color3.fromRGB(29,30,34),
    header=Color3.fromRGB(42,43,48),
    side=Color3.fromRGB(32,33,37),
    content=Color3.fromRGB(26,27,31),
    slot=Color3.fromRGB(49,50,55),
    line=Color3.fromRGB(104,106,113),
    text=Color3.fromRGB(235,235,239),
}
local gui = new("ScreenGui", {
    Name="HORIZON_UI_2_0_PREVIEW",
    ResetOnSpawn=false,
    IgnoreGuiInset=true,
    DisplayOrder=1000,
    ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
}, parentGui)

local window = new("Frame", {
    Name="MainWindow", AnchorPoint=Vector2.new(.5,.5),
    Position=UDim2.fromScale(.5,.5), Size=UDim2.fromOffset(960,671),
    BackgroundColor3=C.outer, BorderSizePixel=0,
    Active=true, Visible=false,
}, gui)
corner(window, 17)
stroke(window, C.line, .22, 1.4)
-- Adapt to landscape and smaller screens, while keeping aspect ratio.
local uiScale=new("UIScale", {Scale=1}, window)
local collapsed=true
local function resize()
    local camera=workspace.CurrentCamera
    local viewport=camera and camera.ViewportSize or Vector2.new(800,360)
    local width=viewport.X < 650 and 360 or 960
    local height=viewport.X < 650 and 771 or 671
    uiScale.Scale=math.min((viewport.X-20)/width,(viewport.Y-30)/height,1.42*1.05)
    window.Size=UDim2.fromOffset(width,height)
end
resize()
local viewportConnection
local function bindCamera()
    if viewportConnection then viewportConnection:Disconnect() end
    if workspace.CurrentCamera then
        viewportConnection=workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resize)
    end
    resize()
end
bindCamera()
local cameraConnection=workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindCamera)

local header = new("Frame", {
    Name="TitleBar", Size=UDim2.new(1,0,0,76),
    BackgroundColor3=C.header, BorderSizePixel=0, Active=true,
}, window)
corner(header,17)
-- Cover the lower rounded corners of the title bar.
new("Frame", {Name="HeaderSquareBottom", Position=UDim2.new(0,0,1,-17), Size=UDim2.new(1,0,0,17), BackgroundColor3=C.header, BorderSizePixel=0},header)
new("Frame", {Name="HeaderDivider", Position=UDim2.new(0,0,1,-1), Size=UDim2.new(1,0,0,1), BackgroundColor3=C.line, BackgroundTransparency=.5, BorderSizePixel=0},header)
local logo = new("TextLabel", {
    Name="Logo", Position=UDim2.fromOffset(15,12), Size=UDim2.fromOffset(50,50),
    BackgroundColor3=C.slot, BorderSizePixel=0, Text="H", TextColor3=C.text,
    Font=Enum.Font.GothamBold, TextSize=20,
}, header)
corner(logo,8)
new("Frame", {Position=UDim2.fromOffset(78,18), Size=UDim2.fromOffset(1,23), BackgroundColor3=C.line, BorderSizePixel=0},header)
new("TextLabel", {
    Name="Title", Position=UDim2.fromOffset(94,0), Size=UDim2.new(1,-177,1,0),
    BackgroundTransparency=1, Text="HORIZON  UI 2.0", TextColor3=C.text,
    Font=Enum.Font.GothamBold, TextSize=25, TextXAlignment=Enum.TextXAlignment.Left,
    TextTruncate=Enum.TextTruncate.AtEnd,
},header)
local function control(name, txt, right)
    local b=new("TextButton", {
        Name=name, AnchorPoint=Vector2.new(1,0), Position=UDim2.new(1,-right,0,13),
        Size=UDim2.fromOffset(48,48), BackgroundColor3=name=='Close' and Color3.fromRGB(87,49,55) or C.slot,
        BorderSizePixel=0, Text='', TextColor3=C.text,
        TextSize=20, Font=Enum.Font.GothamMedium, AutoButtonColor=false,
    },header)
    corner(b,8)
    return b
end
local close=control("Close","×",13)
local minimize=control("Minimize","−",70)

local body=new("Frame", {
    Name="Body", Position=UDim2.fromOffset(0,76), Size=UDim2.new(1,0,1,-76),
    BackgroundTransparency=1, BorderSizePixel=0,
},window)
local sidebar=new("Frame", {
    Name="NavigationArea", Position=UDim2.fromOffset(0,0), Size=UDim2.new(.25,0,1,0),
    BackgroundColor3=C.side, BorderSizePixel=0,
},body)
local content=new("Frame", {
    Name="ContentArea", Position=UDim2.new(.25,0,0,0), Size=UDim2.new(.75,0,1,0),
    BackgroundColor3=C.content, BorderSizePixel=0,
},body)
new("Frame", {Name="VerticalDivider", Position=UDim2.new(.25,0,0,0), Size=UDim2.new(0,1,1,0), BackgroundColor3=C.line, BackgroundTransparency=.65, BorderSizePixel=0},body)

local slots=new("Frame", {
    Name="SixEmptyNavigationSlots", Position=UDim2.fromOffset(10,12),
    Size=UDim2.new(1,-20,1,-24), BackgroundTransparency=1,
},sidebar)
local layout=new("UIListLayout", {
    FillDirection=Enum.FillDirection.Vertical, HorizontalAlignment=Enum.HorizontalAlignment.Center,
    VerticalAlignment=Enum.VerticalAlignment.Center, Padding=UDim.new(.025,0),
    SortOrder=Enum.SortOrder.LayoutOrder,
},slots)
local names = {"Главная", "Аватар", "Игрок", "ESP", "Боевой", "Защита"}
-- Library icons: Lucide 0.456.0, Tabler 3.24.0, Iconoir regular.
-- Sources: github.com/lucide-icons/lucide, github.com/tabler/tabler-icons,
-- github.com/iconoir-icons/iconoir. Original outlines; monochrome PNG + SVG-derived fallback.
--[=[
Copyright (c) for portions of Lucide are held by Cole Bemis 2013-2022 as part of Feather (MIT). All other copyright (c) for Lucide are held by Lucide Contributors 2022.
ISC License

Copyright (c) 2026 Lucide Icons and Contributors

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

---

The following Lucide icons are derived from the Feather project:

airplay, alert-circle, alert-octagon, alert-triangle, aperture, arrow-down-circle, arrow-down-left, arrow-down-right, arrow-down, arrow-left-circle, arrow-left, arrow-right-circle, arrow-right, arrow-up-circle, arrow-up-left, arrow-up-right, arrow-up, at-sign, calendar, cast, check, chevron-down, chevron-left, chevron-right, chevron-up, chevrons-down, chevrons-left, chevrons-right, chevrons-up, circle, clipboard, clock, code, columns, command, compass, corner-down-left, corner-down-right, corner-left-down, corner-left-up, corner-right-down, corner-right-up, corner-up-left, corner-up-right, crosshair, database, divide-circle, divide-square, dollar-sign, download, external-link, feather, frown, hash, headphones, help-circle, info, italic, key, layout, life-buoy, link-2, link, loader, lock, log-in, log-out, maximize, meh, minimize, minimize-2, minus-circle, minus-square, minus, monitor, moon, more-horizontal, more-vertical, move, music, navigation-2, navigation, octagon, pause-circle, percent, plus-circle, plus-square, plus, power, radio, rss, search, server, share, shopping-bag, sidebar, smartphone, smile, square, table-2, tablet, target, terminal, trash-2, trash, triangle, tv, type, upload, x-circle, x-octagon, x-square, x, zoom-in, zoom-out

The MIT License (MIT) (for the icons listed above)

Copyright (c) 2013-present Cole Bemis

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

MIT License
Copyright (c) 2020-2024 Paweł Kuna (Tabler Icons)
Copyright (c) 2021 Luca Burgio (Iconoir)
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]=]
local IconPNG = {
    -- Lucide v0.456.0 circle-check.svg, rasterized at 96x96 with transparent background.
    ["circle-check"] = [=[iVBORw0KGgoAAAANSUhEUgAAAGAAAABgBAMAAAAQtmoLAAAAMFBMVEX///////////////////////////////////////////////////////////////9Or7hAAAAAEHRSTlMAESIzRFVmd4iZqrvM3e7/dpUBFQAAAx1JREFUeNrdmLtrFFEUh8/Oxrx8bSMEBA0KWgR0SZuQpLASNFpICkWtBR9N6kT/gYh1NBZ2gkZEbISkSZFCksZHYdzgElBBNvGtyc5nMa97596Z2QtWOdXM2fObc88597xWZHuSNzb9suG/WxzvbU38SoOQ/OfVYvmjNRRq3iqSv0CKFvLlr2LQmzz5a1jodbb8IFZ6qsqUlefOFft3jpTm7f5cij65ON5fKR0em47et+wBuRj+/PZsxNl3N2St2eQ7wmA9UJknQ8QNC2AqkL+jc3uCsP8x5buDT91M83sC/n0D8Nj0YEB9APxNs7sA+Gkz7joAt1PcCYCm9XKWawC/dOYOAJ7YA7cfgDMa75j1nJp9HzTWku2YuoFbKqczV0GoYlJhDAPMZgN2AnxTGHNAs5INKNWAzeS9Pf0Bg4Z1P+0GuJwHaAdY1mK5mZ/sc9o9qBWdKDhTUwvzZD6gUzViF+BX8gGlBhCl9nHgd1GFmwK+Ks8bRYADyo2tWTPKkpGh1WWAkSJAG0BvXC6a9kr16HNSkRpxcLszbR5Ss2AmPvge4Ls1Nxvqnb8ErMZe3chQgB+/HQz86olURWTJpkBP8S9B6fZEekVk2QIYqIhIkphNEfFiwGqWgo/xu18EGKiICKfTgLBiVA3flxsAdUVjXDlqcQjDClWPXISvlEIvjm8DqKgVxa9aFEgpdjKAaDegblGgyJkAv2oqUOSMI0HdoiA5kmE0+BYFidG6W8vJLKN3i9Ctnsi6BMELb8Bo9LSm3xdPRBDxgigrnXthPbTxlBgA3waIVKQUpADqcQMVaQVSDu+TJYGGTBclCRSm6I90avpGQw1T1AtypE39qTlqWiAyIiLzGWVGKy9mmXEuZM6lUivMLRVj53LfckOZdWhZXVrfdW2K7m23uLF36I3deXRwHk7cxx/nAct5hHMfEp3HUOdBN2+UnrCO0jKTNawP2od193XAeeGIVhpaXmnipelTsjTdy1ua3Ney4EbZKDN9+1pYLQuXXXj1P9djkfNp+Wf/e8Uv/BOhZIOcO9F/aO/7lRcPV7fn/zD/AGNIFJc181OWAAAAAElFTkSuQmCC]=],
    ["house"] = [=[iVBORw0KGgoAAAANSUhEUgAAADAAAAAwBAMAAAClLOS0AAAAMFBMVEX///////////////////////////////////////////////////////////////9Or7hAAAAAEHRSTlMAESIzRFVmd4iZqrvM3e7/dpUBFQAAAQlJREFUeAFjoASwnv8TgE2c6fz//38UsEjY/geCy1gMAon//49pWP3//4u0/v//ji7O9f//DwaG/v//F6DZvB5sCtC8X6j26/7/fxVEx/7/fwlZnPn+/79glUxAhgGSRPz//4cgLJ3//78ixNmBRsPYQMsK4BJATgOMzYGkCOh8JO1AYxdBnQq0EMnDrDCHMPCgORHo9APQwEANVGAwQwJmPXowcEGt//8fLRaY/v+HSqCHKHESTL2geLoBNhVFAuhIEAA7HEUCGEcgAIwtNIn7EIm/GBKY5KgENglQakUSYoZKrAdnMCQJW2hiACY9dABJmMDMhA6g6QmYplEBLFWzosn8wsy6tAEADU5OOKHdzyEAAAAASUVORK5CYII=]=],
    ["contact-round"] = [=[iVBORw0KGgoAAAANSUhEUgAAADAAAAAwBAMAAAClLOS0AAAAMFBMVEX///////////////////////////////////////////////////////////////9Or7hAAAAAEHRSTlMAESIzRFVmd4iZqrvM3e7/dpUBFQAAASZJREFUeAFjIBvEXkWl4eD+X1QaDv7/R6XxS7Cu/48CfgVAJdDEgTIQcS508f//F4Al4jElvkJNuozqEFuoWf//G6BKMEOdhuF0mAhBCYv7f5uxScSCnAMJQhQJVohDwZ5GkYB6H+xQZAmgE38FgAIN5HRkCZ7/f4GmsN7/fwBNIv7/ZxDbHhwayBLrIQHHBbYEVQLsHlYMif//FUBsJiiHCAmcRuG0HKdzcXoQZ5DgDERYImrACN37UB0g76C6CgouoUqA4m+pAnPN//9/gVqQJIAamkBsG7AWJIn70FQJdNwPZAkOaCoAO84ASYL//3d4ngMGGkIi/v8FmIT9/w8ICYP1EI+BAO//r7BEDcwGSAme4/8vWDbAmXFwZjWcmRN3diYNAACHurQBxbCXRAAAAABJRU5ErkJggg==]=],
    ["user-round-cog"] = [=[iVBORw0KGgoAAAANSUhEUgAAADAAAAAwBAMAAAClLOS0AAAAMFBMVEX///////////////////////////////////////////////////////////////9Or7hAAAAAEHRSTlMAESIzRFVmd4iZqrvM3e7/dpUBFQAAATdJREFUeAFjoCNgqrr/Zzk28f7/QPBDAUMiHiT+//9VdHFWiPj//wGYGq4HMNf+//8VzYb7/7+D6Pr/f1Ft4YCaATSxAUVCH6IBpOUTmhUXIAxemAooWP+/AMJg//8LReL/fwOYs/+gSWCyCEngMAqn5Tidi9ODOIMEZyDiDHbcEQV0MPaotYVqALo6FIwQroKABQxc/xcAEcxRQIP+lDIwhK9SYOAHyX+ASugCUxQ0sIB+h5gIBuf//4WJQ1wBDTCgDYugwlx/IXbdB9tijwhSoEf/FrDfh3r0/v9LSBJANtBOkATQ13AbuP6DYoYd5G4GBp7/P5DjEhiKTJAI1v//GbtE/P8DcHEUo+ARjm75eaSwRnEuclJC8SBqGkMKkvt/kSWQAjEWJdpQgh0ZoEQUCkCJWpIAAEq/El0TcwDhAAAAAElFTkSuQmCC]=],
    ["eye"] = [=[iVBORw0KGgoAAAANSUhEUgAAADAAAAAwBAMAAAClLOS0AAAAMFBMVEX///////////////////////////////////////////////////////////////9Or7hAAAAAEHRSTlMAESIzRFVmd4iZqrvM3e7/dpUBFQAAAPxJREFUeAFjGHYgYu3//7daMYTZz/8Hgz8FqOIc9yHi////bUBRDxcHyiDpYVoPFDgRzMBg2gNk/FKAS+gC1TVBmBpAvZdg4qxADtxkDqCiACjb/v//Qwhzdf7//wy14f7/XxBTIOat//8XYgvv//8gvUAzICay/v9/ASzR//87RCHIRSBW/f8fIIr5//8FIK9AfAHyBNf//wZAiuf/X4gL/hYA/Qm29/7/A2CRrxD9QOfrQkyNB8uvB0sDKaAp7BBLeMAUxEAgBXQj0///UGvxSeA0CqflOJ2L04M4gwR3IOIMdpwRhTtqcSYG3MkHZ4LDnURxJ2rc2WCoAwDBLxoGX9ut8wAAAABJRU5ErkJggg==]=],
    ["swords"] = [=[iVBORw0KGgoAAAANSUhEUgAAADAAAAAwBAMAAAClLOS0AAAAMFBMVEX///////////////////////////////////////////////////////////////9Or7hAAAAAEHRSTlMAESIzRFVmd4iZqrvM3e7/dpUBFQAAAQtJREFUeAFjoA+I/f///1Vs3PtA1v8AmDgriPcXzASx/n+FScSDuQgJmBawBrgEiAvVAtQQABKBSkD4EA1AFUgSMC0QBXAJIBsiApEHklDnQjhAkheqCOJciGIwyYtQA7cQTLLehZuKpgWuDl0LXBmmFiQNqFogDsOiBewwbFrADsOqBRWgOoxULbFICQBZSyg0CMEJA6gGrgWWFCABDzcflBYQDkCKEZAWhP1ITkJ1MZKT0ByM5CRULyI5CUMC5iQMo7BqgXkLZCKS7bFXYQEBEgRJQkMLlD8gQQf2KMhYSKCAJCC6wUEDMheeEqH2QYyA89HjDTklIgIaFqRQLWgScC+iRiZa1NIQAAALO1fPmyFlxwAAAABJRU5ErkJggg==]=],
    ["shield"] = [=[iVBORw0KGgoAAAANSUhEUgAAADAAAAAwBAMAAAClLOS0AAAAMFBMVEX///////////////////////////////////////////////////////////////9Or7hAAAAAEHRSTlMAESIzRFVmd4iZqrvM3e7/dpUBFQAAAQ9JREFUeAFjoAQw994wwCoR////V2ziWv+BYBGmOPt9kMTfAmzi12sxZJiigKr/KDCBdC1VQAj3gkz5D1TLDmbcgEnpgrlNIKYGmHkJKtEPshUsDpQBmfYDKgFkrwiAmcvaBVQFZf//j+pCOH9UYkAkzv9HSYHM//9AWev/w+MPHIf/f0FZ9f8XIEtw/f8OZdn//4Aswf//M5TFC1cCNeAClMUBTxbQRNMAS4n/4Uywsv/wRNqPnDHi4ekNZAnCwaz/4VaAvISwHpivkLwL5EHzEjBfIec3oH5IjgHlH5RgAGoByYDEUTMo03mgTLMFUPwPIkMh5U1IvkIFkLwEyVdoMiA9WMSBTlv/B8VBpAIAcdXo/JCZqQAAAAAASUVORK5CYII=]=],
    ["refresh-cw"] = [=[iVBORw0KGgoAAAANSUhEUgAAADAAAAAwBAMAAAClLOS0AAAAMFBMVEX///////////////////////////////////////////////////////////////9Or7hAAAAAEHRSTlMAESIzRFVmd4iZqrvM3e7/dpUBFQAAAUtJREFUeAFjoCswX/v//61iMDP2KkKYqfc/GNwwAHLu/0WI90PE////A5T5/x8uEQsT////B7IEF1DgVzADg+l6IOMSkgSQfx3CigHKBMAlgBq+w9TY/v//FS6x/v9fBbh1INOgEqwgc+EAyINJ6CJrYGCIh0v0//+E7m6I5/7/L4BL3EeS4PiPCAGoBESAF+FWmFGQQLT//wF7eNf/X4BdYv3/AOwS9/+D4gALQAp9mAsglmNKQGMQKSJRzUCOelyGQwAzclAgA9b/v7BLcCGHETLg//8ZI9ygYXQBI6ShAg1Qx6FKsP//D4lpiATCKH1QYoRKfEWymuk+LM2A1CMFvC6cB5JA+AioAcb5/x+Yki4j3AqP0P//QYnvKIRTi6QbGJZAcxHZAJ4CQIEMz1DI7gZJMJ+HZyhEMgbHIDMscyIlb2gMImVnegEAIl4XK3n87uEAAAAASUVORK5CYII=]=],
    ["server"] = [=[iVBORw0KGgoAAAANSUhEUgAAADAAAAAwBAMAAAClLOS0AAAAMFBMVEX///////////////////////////////////////////////////////////////9Or7hAAAAAEHRSTlMAESIzRFVmd4iZqrvM3e7/dpUBFQAAAGRJREFUeAFjIAewrv+PBn4FgCUwxIEyIHEuTPH//xcAJeKxSXwFm3QZ3VZbsFn//xugSzD//w+WwHQoYYnYqzgk7qPpIiyB0yhSXYXDgziDBGcg4gx2nBGFO2rpAUbT1Wi6IgAAxWmtFN41S5gAAAAASUVORK5CYII=]=],
    ["users-round"] = [=[iVBORw0KGgoAAAANSUhEUgAAADAAAAAwBAMAAAClLOS0AAAAMFBMVEX///////////////////////////////////////////////////////////////9Or7hAAAAAEHRSTlMAESIzRFVmd4iZqrvM3e7/dpUBFQAAAW5JREFUeAFjoCNgqrr/Zzk28f7/QPBDAcjsABFwEA8S////KgMDB4iAA1aI+P//AQz8IAJZw/UA5tr//78CdQAJuA33/38H0fX//ypACCgAqgJrB5rYACGgQB+iAaTlE5SAWXEBwuAFqQATELD+fwGEwf7/F5SAgP//DWDO/sPAwPz/L0IChYXGxS6BbBQTwiicluN0Lk4P4gwSlECMRwpE5GBnuI8U7MgRBZT4gRSF6yHiIHcCdSOi0Bam4zJQ9/3/n5FcBQNAB9nDfc50/v//P6UMDOEgWgHJvbrAFAUOLGZg6rrEwNAP8+H5/3+hgch8HxSKvNDAAtqwCGabFtTvYC/aI0IT5G6gk85DLLkPMhcGdEFOqgeHNlAj1AawLZBkCvIJD0oQAJ10gIELHKb6CI9CbPwEjcN4oBIkwAMMXFawBDzCkaIdnE7WI+cHkFtgEohUhEha90HBiE0iFpTdwLJIAM4HyyIBdD4NAQDrHiTUhOJALwAAAABJRU5ErkJggg==]=],
    ["info"] = [=[iVBORw0KGgoAAAANSUhEUgAAADAAAAAwBAMAAAClLOS0AAAAMFBMVEX///////////////////////////////////////////////////////////////9Or7hAAAAAEHRSTlMAESIzRFVmd4iZqrvM3e7/dpUBFQAAATlJREFUeAFjoACEr/3//1QrhjDz+v9g8MsATfw8RPz//78oMkxQ9SDwRwFJIhYocCuYgSEUaM//qwhxdiD3MIRpBWQ2wCWABkHFGRhsgA5A0vAdoT0eoSUexSnM9/9/hTrp//9LyE7U/f8X4jCu//9R3M78//8BqElINoBA/f/PYPo8VAFDLNQHPP//QHVC/Xr/P9wskNlcEHkkCaAZC4AkP9REhFEM9v8/gMkL6HHAC/ZJP1gfCuACu3P9/wB0CVZwcJ3HlGAGu+c/zC0IyyFiCIn7f3FIoLFwSiAsh0tALEc4Fy4BcS7Cg3AJiAcRQQKXgAQJIhDhEpBARAQ7XAIS7EgRBfUgNKJwRi3uxIAz+eBMcDiTKO5EjTMb4M44OLMa7syJMzsDZaB6fqGJA0E40PxTrRjCxAMAbS8WzHtkz0EAAAAASUVORK5CYII=]=],
    ["globe"] = [=[iVBORw0KGgoAAAANSUhEUgAAADAAAAAwBAMAAAClLOS0AAAAMFBMVEX///////////////////////////////////////////////////////////////9Or7hAAAAAEHRSTlMAESIzRFVmd4iZqrvM3e7/dpUBFQAAAVRJREFUeAFjoACEr/3//1QrhjDz+v9g8MsATfw8RPz//78oMkxQ9SDwRwFJIhYocBckCiKuIsTZgdzD9v9/rf//2QrIbIBLAA06zHD+/wXe/38YbIAOQNLwHUQYMP//X8AQj9ASD3IKL0jh+v8XGJjv//8KddL//5cYGOr/f2Jg0AdqZdD9/xfiMC6gIQxAK4AGcAAtYQAaeABqElAZUBtQGYSs//8ZLHEepIAdpBbELmBg4IGwgTqBqnggNsaDFAFFQOHCBZbnB9kNsv0DWN8CsBDIRLBSmEZ7sLQ90O0gC0GKgNqBDgH6CSTdDxZa/z8AJMEKDg+INEQIRQJCngcLgZ0G9gjYoSD3IKIIGVBXAqflOJ2L04M4gwRnIOIMdpwRhTNqcScGnMkHZ4LDmURxJ2qc2QB3xsGZ1XBnTpzZGSgD1fMLTRwIwtf+/3+qFUOYeAAAt9jKoPTL0x4AAAAASUVORK5CYII=]=],
    ["user-round"] = [=[iVBORw0KGgoAAAANSUhEUgAAADAAAAAwBAMAAAClLOS0AAAAMFBMVEX///////////////////////////////////////////////////////////////9Or7hAAAAAEHRSTlMAESIzRFVmd4iZqrvM3e7/dpUBFQAAARJJREFUeAFjoCtgqrr/Zzk28f7/QPBDAUMiHiT+//9VdHFWiPj//wGYGq4HMNf+//8VzYb7/7+D6Pr/f1Ft4YCaATSxAUVCH6IBpOUTmhUXIAxemAooWP+/AMJg//8LReL/fwOYs/+gSWCyCEngMAqn5Tidi9ODOIMEZyDiDHbcEQV0MBigOhYIbGE6LqOKA10FAyiuYjr///+fUgaGcBCN7CxdYIoCBxYzMHVdQpI4//8vNBCZ7yOHItCGRTC2FrIt9siuXP//M5x9H9lc3f9/kXwNtQFsC8L3PP9/ILu9//8BeGQgTAXbCIuSeLgSqAGwEIZHOHq0r0cNa1a4BFpSQvBxStyH+wiNH4uWI9H5NAMAQ5jTtjd4Ff8AAAAASUVORK5CYII=]=],
    ["box"] = [=[iVBORw0KGgoAAAANSUhEUgAAADAAAAAwBAMAAAClLOS0AAAAMFBMVEX///////////////////////////////////////////////////////////////9Or7hAAAAAEHRSTlMAESIzRFVmd4iZqrvM3e7/dpUBFQAAAUNJREFUeAFjoASwrv8VgFX8/v//f7HIMJ//DwR/DNDFmfpB4v///1BAk6gHCjZbAInvqOKxQKFDDAw6QOoqsrgNUOAyiGELZBxGiGsAudchzFogswkmzo5kKdgRBVCJ9UBnwh3DBHT2LwiTC+gxJOczAz26AMyK//+/AdklHP//f4WZhOJ4oJcgZoE8jOR4kJf+wyUQjgd5CS6B5Hiwl+ASDHDHg70EEoFKgBwPigtQnAC9hJAAO/6PAShOQF5CkmBgB8r8AJr4F2QisgTYVpgbUCTAcQGKEwwJUFyA4wRDAoMxWCWgMQ6TYIYy1v+/hCqhC43aeEjIwSWA4QlJDPDkA5FAJB94ggNLICU4eBIFSaAkUViiBkmgJGpYNgBKoGUDaMb5/x8j40CyGhigZTXcmRNndoYkNlCiwyKz/hdWcWIBAB2MV+qrLXrwAAAAAElFTkSuQmCC]=],
    ["layers"] = [=[iVBORw0KGgoAAAANSUhEUgAAADAAAAAwBAMAAAClLOS0AAAAMFBMVEX///////////////////////////////////////////////////////////////9Or7hAAAAAEHRSTlMAESIzRFVmd4iZqrvM3e7/dpUBFQAAAOxJREFUeAFjoASwr/9VgE1c4z8QNGGKW4DE//9vRhe3gYj//38YVbwGKPS3SP0+kDqOLF4LEgfazA6SuQ4XZuoHcv8YgJjM54HMHwoQcWaQ+C+wOJCzHiQD5jAhK4JpB3F1QcbCxYEyIAsvARlAvQjrYE75BaQwnA72FJC8//8odgmcRoEsv4HNcpzORfY4igeBMr3YgwR3IAJBDI5gxxpRWosxo9ZqEZA4D1WElBhs/v8BhxXUOnjyATkFSIF8gRHsPzCdjhzPOKIWpigAxGQl2ufgBNdsQS2fA835Oxx9TiA7o/gcDcB9TiYAAHL9cIKoaOSgAAAAAElFTkSuQmCC]=],
    ["search"] = [=[iVBORw0KGgoAAAANSUhEUgAAADAAAAAwBAMAAAClLOS0AAAAMFBMVEX///////////////////////////////////////////////////////////////9Or7hAAAAAEHRSTlMAESIzRFVmd4iZqrvM3e7/dpUBFQAAAP5JREFUeAFjoCdQXfX//6ogTHGb/2BwGIc4hgwHTPz//wZkcab7////aVVgijj///9fBSQJ3f//fxiAGMz9//9fQpK4//8vWBwoA2Si2LAIxtZCtsX+/y+EqvX/P8PZ55HN1f3/B8Zk/v8fagMaj+f/D2S39/8/AGXpI5kKtvETlBUPVwI14CvcHSjBwAF34/r/AcgSrHCJ//+Rg4eB6f9/uARqUBMjgcMonJbjdC5OD+IMEpyBiDPYcUYU7qjFmRhQkw+yd1ESHNwbaEkUCJC0ICXqVhQtyNkgHkULUsZhRdWClNXQtCBHCKoWBIhHzgqoWnBIMMReJSL/UwEAAIko31cl+dIaAAAAAElFTkSuQmCC]=],
    ["maximize"] = [=[iVBORw0KGgoAAAANSUhEUgAAADAAAAAwBAMAAAClLOS0AAAAMFBMVEX///////////////////////////////////////////////////////////////9Or7hAAAAAEHRSTlMAESIzRFVmd4iZqrvM3e7/dpUBFQAAAHpJREFUeAFjoBNgXf////+rEHYskPkrACoBEv//F8K+D2L/grC5QGwUif8LwOx4MBvJqP//v0JNuoxqpy3UrP//DVAlmP//h0qgO3MwSNyHehoBoCKxUE8jAKbIKCAAcAYizmAfnKkEZ6LGmQ1wZhycWQ1n5sSdnWkNAEZZqRMO/9XLAAAAAElFTkSuQmCC]=],
    ["shirt"] = [=[iVBORw0KGgoAAAANSUhEUgAAADAAAAAwBAMAAAClLOS0AAAAMFBMVEX///////////////////////////////////////////////////////////////9Or7hAAAAAEHRSTlMAESIzRFVmd4iZqrvM3e7/dpUBFQAAARNJREFUeAFjIBcw916FMGJvGCCLW9z//xfCAjKakZT/BwIIG8SCaWK9D+L9DwCzwcy/YDbDehDz/v8GEJsDxPr//xeIzQ7WHP//E4ij//8r2OACMPs/0Dqe/38VGBiY7v8/AHTKf7Cq+P+XQA74//9HAGv///8gi3X/fwVLLIDZBDOdC1mCCyIBZSNJMNiAxA+DmRAJ/f8fIP6JOv9nKYTFD7acHyaBABAhHrA+FBAPcjTUQDQJkLXsECcig/Vgn4PDDRob4BiBhygo1KCxgcqNR8QGLEYgtjKDQgNF4hc8elElkJwxKjFkJOCRCcwPKAnpMoxpi5LMwAkFBpATJjRzIGURhFlwgJpgWeEyvyB5nAwAAIZ3KW5QFz4BAAAAAElFTkSuQmCC]=],
    ["smile"] = [=[iVBORw0KGgoAAAANSUhEUgAAADAAAAAwBAMAAAClLOS0AAAAMFBMVEX///////////////////////////////////////////////////////////////9Or7hAAAAAEHRSTlMAESIzRFVmd4iZqrvM3e7/dpUBFQAAAVZJREFUeAFjoACEr/3//1QrhjDz+v9g8MsATfw8RPz//78oMkxQ9SDwRwFJIhYocCuYgSEUaM//qwhxdiD3MIRpBWQ2wCWABkHFGRhsgA5A0vAdoT0eoSUexSnM9/9/hTrp//9LyE7U/f8X4jCu//9R3M78//8BqElINoBA/f/PYPo8VAEc8Pz/A9WJ7FeICMhsLoh8LNjDEPL8/wVAkh9i4v3/CNL+/wcweQFdghfsk36wPhSjuMDuXP8/AD3WWMHBdR5Tghnsnv9gY1EBWIyKEhDLIe6E0hDLIc69D3Eb6/+/cOdCPHj//w+QRD9YAuJBSJAAY/p6kGrtf3BgQIIEEoissPQGMhESiLBgh4gjBTssoupB4uBIhkYULGqZotb/WgpWAo1a3IkBZ/LBmeBwJlHciRpnNsCdcXBmNdyZE2d2BspA9fxCEweCcKD5p1ox459oAACB4zGkYpPaRwAAAABJRU5ErkJggg==]=],
    ["arrow-up"] = [=[iVBORw0KGgoAAAANSUhEUgAAADAAAAAwBAMAAAClLOS0AAAAMFBMVEX///////////////////////////////////////////////////////////////9Or7hAAAAAEHRSTlMAESIzRFVmd4iZqrvM3e7/dpUBFQAAAIZJREFUeAFjGIYg9ip2cdb//wOwSsT///8VhwbsWoAasGoBa8CmBawBixaghq///wNl0bWAhP7/B0ljamD4/x8sj6EBJIGuBcIHSqBrgXBBEqhaoDyQBKoWKAcsgaLlPoQNlgCq+oskAdYNkWBFkoDGEEQCS3xBJTDBqAQGuI8IVuKywZAGAI6vh9+TYGgbAAAAAElFTkSuQmCC]=],
    ["arrow-down"] = [=[iVBORw0KGgoAAAANSUhEUgAAADAAAAAwBAMAAAClLOS0AAAAMFBMVEX///////////////////////////////////////////////////////////////9Or7hAAAAAEHRSTlMAESIzRFVmd4iZqrvM3e7/dpUBFQAAAIlJREFUeAFjGIYg9ioOift/cUj8/z8qQVACGqxQCaRAvv8/ACHB+h8RyPf/f0VIxCNJxP8HawFLsP6HqAIDKAcsAVWEogUkgaIBxgVJoGqA8oESaBqgWoAS6BogWv7/x9AA0fL/P6YGsBYQQNcA1gICGBqgWjA1QLVg0QDWgk0DWAtWDXiywVAGAGJ3h9+fF2j3AAAAAElFTkSuQmCC]=],
    ["camera"] = [=[iVBORw0KGgoAAAANSUhEUgAAADAAAAAwBAMAAAClLOS0AAAAMFBMVEX///////////////////////////////////////////////////////////////9Or7hAAAAAEHRSTlMAESIzRFVmd4iZqrvM3e7/dpUBFQAAAPhJREFUeAFjGNyA9f5/IPgbgCFhDxL///8zujgTWANQiwKaBC9E/P//C2gS6///AFH9/3+hinP8/78ARHP9/9+AcM96sOEQDtiqXxC3gcX/X4JI6II5YPOAukHAACLBDOGBzI0Hs67CDI4Fc7+CTbqM7ilbsFlwUxAAaB5YAsrVuP+3CcpEkQB6Be4JFAmwq6H+RpZgh7izAEPC/v/fAvb70GBHlqgH+V33/3cMifUgU9ihliBL/P8PjCImOIcICZxG4bQcp3NxehBnkOAORJzBjgwISeCIWpyJAZJ80AAo+UATHCoAJ2RIEkUBEH9CEjWKOGaGGyQAAELaTdINSiLWAAAAAElFTkSuQmCC]=],
    ["heart"] = [=[iVBORw0KGgoAAAANSUhEUgAAADAAAAAwBAMAAAClLOS0AAAAMFBMVEX///////////////////////////////////////////////////////////////9Or7hAAAAAEHRSTlMAESIzRFVmd4iZqrvM3e7/dpUBFQAAATZJREFUeAFjoBtQX/v/VyuIEbH+/60ihLjNfxC4zsBQC2YcholzgLn//x/SgTIaoBLrofy/96GMXxBxrv///xQzsIKlfwUwmJ///38BWKL//18DIMUElPmlAGQw3///AyTO/P//JbAC9v//C8AM3f//QSp5/v8FqQOC2KsQmun+/wNASv//Z3Rv2f//BCTrwdIogOf/d7BjISYjAXawg++DbUIBzP//Asn//zHDDiyGU+I8plGs///gsxync3F6EBgk6BL3wcELDERIKMMBMB7A7un//xVVoh4S7Ay8//8HoDr2/wVYKKNoiYfHQzyKFqAGmDokJpoyZDaKKmQOqrkIHqqxSFxUDQg+mgaEALoGmAiGBpgQpgaIGBYNEC3YNIC1YNMA1oJVA1gLNg1gLVg1IPIH3QAAYL7uRxI/lXQAAAAASUVORK5CYII=]=],
    ["play"] = [=[iVBORw0KGgoAAAANSUhEUgAAADAAAAAwBAMAAAClLOS0AAAAMFBMVEX///////////////////////////////////////////////////////////////9Or7hAAAAAEHRSTlMAESIzRFVmd4iZqrvM3e7/dpUBFQAAALVJREFUeAFjoBuIvY5D4v7/Q9gl/v//X4BL4q8BDon/P7BL3P///zJWCS2gnkXYJBhsgdYEYJNg6P///5cCNglmoDXfsUkwsAOtQfcnWIJBB9OfEAmGegx/QiWY1qP7EyrBwIruT5gEA7o/4RLo/kRIoPkTSQLkz6/YJED+/EuSBE6jcFmOy7m4PIgrSHAGIq5gxxVRuKIWZ2LAlXxwJTicSRRnosaZDXBnHOxZDWfmxJmdaQsAZqrJ6YdNRekAAAAASUVORK5CYII=]=],
    ["bot"] = [=[iVBORw0KGgoAAAANSUhEUgAAADAAAAAwBAMAAAClLOS0AAAAMFBMVEX///////////////////////////////////////////////////////////////9Or7hAAAAAEHRSTlMAESIzRFVmd4iZqrvM3e7/dpUBFQAAAI9JREFUeAFjGNQg9j8QXMUicR8k8ReXxH9cRmGTAAGaSrCuB1sNBb8C4BIo4kAZmDgXqvj//wugEvHoEl/hJl1GttEWbtb//wbIEsxw16E7k2YSseDoA5OoEvfB0QcmoRKgKILzoExw7IMiFUMCpBGnBE6jcFpOyLk0DyscEYUzanEmBpzJB2eCw51EBx0AAG0NGN5U4RIHAAAAAElFTkSuQmCC]=],
    ["sun"] = [=[iVBORw0KGgoAAAANSUhEUgAAADAAAAAwBAMAAAClLOS0AAAAMFBMVEX///////////////////////////////////////////////////////////////9Or7hAAAAAEHRSTlMAESIzRFVmd4iZqrvM3e7/dpUBFQAAAONJREFUeAFjoAjEXsUhcf8vDon//2kosf4rsuXxv5CUBiCcy4qk8f9/iBaIBiQJINsAxmZGVgXUvQDG5oKaC9PSAGNyIBvLwLwCSFjc/9sMpLrgpsKC8D8QYAlGoD0ggGQ+zJMQCYTnEK78FcAKlEW3gef/X6AprPf/H0CTiP//GUTZozgWYgXYi1xIlgCdCXTkeoh7WEESEBGG+///A4P7/38FkAQTKAQhIrglcBqF03ICzsXpQZxBgjMQcQc79ojCGbW4EgPO5IMzweFMojgTNc5sQI88CAVQy7EEI5a0TgIAAGxF1KNzESEaAAAAAElFTkSuQmCC]=],
    ["chevron-down"] = [=[iVBORw0KGgoAAAANSUhEUgAAADAAAAAwBAMAAAClLOS0AAAAMFBMVEX///////////////////////////////////////////////////////////////9Or7hAAAAAEHRSTlMAESIzRFVmd4iZqrvM3e7/dpUBFQAAAF5JREFUeAFjGAWDEMRexc5muP8/AMZk/f8XReIrjBmPIhH/H6aF9T9CDQoXoQSVj6YBIYCuASaCoQEmhKkBIoZFA0QLNg1gLdg0gLVg1QDWgk0DWAtWDWgBPgoGFwAAvlpJYmGh5XMAAAAASUVORK5CYII=]=],
    ["check"] = [=[iVBORw0KGgoAAAANSUhEUgAAADAAAAAwBAMAAAClLOS0AAAAMFBMVEX///////////////////////////////////////////////////////////////9Or7hAAAAAEHRSTlMAESIzRFVmd4iZqrvM3e7/dpUBFQAAAGVJREFUeAFjGAVIIPYqdnHW/3+xS8TjkGD9//8rDg3/A4amBkTYoGm4D+Oh23AfxkW3AcbHcBJMANNJEBEsfoAIYfMDSAyrp0GC2D0NFMUeSkAtOEIJqAV7sAK1YNWAO5WNAsIAANKtX/YIyRYEAAAAAElFTkSuQmCC]=],
    ["chevron-right"] = [=[iVBORw0KGgoAAAANSUhEUgAAADAAAAAwBAMAAAClLOS0AAAAMFBMVEX///////////////////////////////////////////////////////////////9Or7hAAAAAEHRSTlMAESIzRFVmd4iZqrvM3e7/dpUBFQAAADZJREFUeAFjGAWxV3FI3P8fgEviK3aJ+P84tLD+Hxla/pImgdMoXJYPBw24kw/OBIcziY44AAB6DUmPv01+VAAAAABJRU5ErkJggg==]=],
    ["feather"] = [=[iVBORw0KGgoAAAANSUhEUgAAADAAAAAwBAMAAAClLOS0AAAAMFBMVEX///////////////////////////////////////////////////////////////9Or7hAAAAAEHRSTlMAESIzRFVmd4iZqrvM3e7/dpUBFQAAAR5JREFUeAFjoBAwd/3/v8IAU5z9/n8g+FuALs50HiT+//8fBTSJWIj4//9XUcVZgUJLFZiigFQAikT8//+LQLTW//+X0DR8h7Dq//9B0wA1gR3FLKCGrzD2+v8XsGlgYND//xmrBgau/z+wagCq+oWhIRbkOab/f9E1sEKE/v9H1xCPJoHQAFYANwpJA1gB3HJdVA0I5/ajakB48Px/cKTBTYQHCdQRMA2IQIRIIDkBFuwQCSQ3wyIKLIHuZrgEmifhEtg0gCWAfBhARAxQApR2YAARMUAJrBqAEtg1ACWwOQksgc1JUAlsGkASEH49WnoG5xcMJ0HSPxYnoXgaJcsANfyFip9AyWRoTsSenInRAHQrdg1ACewaIAmfGgAA8nw7P4x9ZwUAAAAASUVORK5CYII=]=],
    ["person-standing"] = [=[iVBORw0KGgoAAAANSUhEUgAAADAAAAAwBAMAAAClLOS0AAAAMFBMVEX///////////////////////////////////////////////////////////////9Or7hAAAAAEHRSTlMAESIzRFVmd4iZqrvM3e7/dpUBFQAAAL9JREFUeAFjGOyAaf0vBawSuv//X8Iqsf7//19YJf4DAWkSOI3CaTk258beMIAxmXuvIknc//+3GcKyADJRJP7/B2li7gUykCViQU792wxUDgTIRoFMgAKYmQg7IeIIV6BoQlcO1fT/P6ZyaGDhiKmBlGD//78AqwTv//8XsErU////HasEKEiwW/H3PlZLeP9/r8dqCVAUKIfVigKgaVitAEtiswJsHDYroLKYVkDNQ5cAC0FI1FQKTk4QcvACALqmkV532Q4MAAAAAElFTkSuQmCC]=],
    ["hanger"] = [=[iVBORw0KGgoAAAANSUhEUgAAADAAAAAwBAMAAAClLOS0AAAAMFBMVEX///////////////////////////////////////////////////////////////9Or7hAAAAAEHRSTlMAESIzRFVmd4iZqrvM3e7/dpUBFQAAAPhJREFUeAFjGOyAdf2vAKwS6////4VNnOs/ECzAIhEPkviK1aTLtljN+v/fgPn/f6wSDAz3/2KRuP/fgCH2KlY7CrD7r/7/AewS+v+/Y5fg+f8fe4gw/celBRhW2BzFYAMKksOY4jog8f//F6GLawAFf/QDiSZUcXag0C8FpvP///9F8Sb7/f///xgwMDCDZJAcjeDDVEB9gGQCxEykuIPbCXIFNB5ZUV0JcjfEGns0fwF9+hnM6EdPAvH/f0CjDi2G2P//gUc2ZvTjl4D7COrf/5DEAkxpqBKwdFcPCXBkAHEmODWjAmjaBsYpKoClYFY0GRz5Z2gCAJ2i2raOLo7YAAAAAElFTkSuQmCC]=],
    ["run"] = [=[iVBORw0KGgoAAAANSUhEUgAAADAAAAAwBAMAAAClLOS0AAAAMFBMVEX///////////////////////////////////////////////////////////////9Or7hAAAAAEHRSTlMAESIzRFVmd4iZqrvM3e7/dpUBFQAAAOxJREFUeAFjoDNg6r2hgFVC9///S1gl+v///4FV4v7//39Jk8BpFE7LcTqXZH9HrL+KRVi16z8QBGCIx4KE////is1vYIChBSS4BpuW//9bFbiwafn/n4GB6/8vYJgYYErw//8QDwzGZmwSrCDTUHwDkoj/vwDsbJSgvw/kgSQYLO6jSsQC9a8HO4m5FyNgIBJYwH+QUdij/C/2eAJ6AjMQwRECDElshq1fAAwsVMNif7UqMLADzUE3DBQZK2KBYkDDUL0NiaQLoAAGBg1GvBZAwww9JYANQZNApB0MCeTgp7UEKCaxAlBM0g8AACAbtSS07u4bAAAAAElFTkSuQmCC]=],
    ["walk"] = [=[iVBORw0KGgoAAAANSUhEUgAAADAAAAAwBAMAAAClLOS0AAAAMFBMVEX///////////////////////////////////////////////////////////////9Or7hAAAAAEHRSTlMAESIzRFVmd4iZqrvM3e7/dpUBFQAAAP9JREFUeAFjoDNg6r2hgFVC9///S1gl+v///4FV4v7//39Jk8BpFE7LcTqXZGC+/ip24f///wdgiscChf///4rpILA4Fi08QME/2LTU//9TzIVFC9CkAwxc/38Bw8QA3SQFBv7/H+KBwdiMatJ3BpAEK8g0ZN/cB5rEEP9/AdjVyEF/H2gSWILB4j6KRCxI+3qwk5h7MQIGIoEFYA0qiEWYQQUGQE9g1wL0BGlaYq9i18IE9Fg8tgTHCxQEainAkFgPMqb+/wUsTgKGFC8olFGBPth4dkxL7v//BKHQLAHGN9gLGJbE//8FdRuaJfehKjEsAUchmIEmAY5CFAY9AAA54quYggLVQgAAAABJRU5ErkJggg==]=],
    ["man"] = [=[iVBORw0KGgoAAAANSUhEUgAAADAAAAAwBAMAAAClLOS0AAAAMFBMVEX///////////////////////////////////////////////////////////////9Or7hAAAAAEHRSTlMAESIzRFVmd4iZqrvM3e7/dpUBFQAAAN1JREFUeAFjoASwrv8VgFVi/f//v7CJc/0HggVYJOJBEl+xmnTZFqtZ//8bMP//T4oETqNwWo7TuTg9iDtISARR50F2////ZymqeC1EGASuI4vrIMT//z+E5J77yBJ/EW4DevrH+f9APuv/P/3I3r///5dC//8GBgaO/z+Y1v//iyRRANQFDA4uoGp2JInYqyDjDjAw8ICMAfGQAP//D1ACDeCUAJsCNg8jOsASmBECdCkDA9jN6LEBiqX1IF9iSIABlqiCSGBNV6RLQPBQl7gPjGoQxgCgqEaLbloDAM8N2eKlcPACAAAAAElFTkSuQmCC]=],
    ["wall"] = [=[iVBORw0KGgoAAAANSUhEUgAAADAAAAAwBAMAAAClLOS0AAAAMFBMVEX///////////////////////////////////////////////////////////////9Or7hAAAAAEHRSTlMAESIzRFVmd4iZqrvM3e7/dpUBFQAAAHZJREFUeAFjGLyAdf1/JPArAC6BIg6UgYlzoYr//78AKhGPLvEVbtJlBob//2EG2MLN+v/fAFmCGc4EMxASCCYeCXRACwlUa2kjQR9/wDjIbOpK0C0+MAMVjwQwwSH4iAQHTqIICUQSxZmocWYDnBkHd1YbdAAAzJK/gsV/1MwAAAAASUVORK5CYII=]=],
    ["pants"] = [=[iVBORw0KGgoAAAANSUhEUgAAADAAAAAwBAMAAAClLOS0AAAAMFBMVEX///////////////////////////////////////////////////////////////9Or7hAAAAAEHRSTlMAESIzRFVmd4iZqrvM3e7/dpUBFQAAAKlJREFUeAFjoBtgv/8fDv4WIEnUI8T///+OJHEeWeIPkgSy+P//KBJwJtP/v0gS6/8HwJis/38NiETsVSDB9f8rkkT8/wVA8j7IodgkwL6hogTv/0/YJfj/f0CSgPCoLaH//wJ2CYg7CEpAfEVtCaQ4I0sCEtFkStz/r4BFAj1No0ggp2kUiR8oeQ1sAERDA5oEhvEQAMmcKMZDQD9GtoQCDpAWlIxMDwAAar4M3t+yUpEAAAAASUVORK5CYII=]=],
    ["hat"] = [=[iVBORw0KGgoAAAANSUhEUgAAADAAAAAwBAMAAAClLOS0AAAAMFBMVEX///////////////////////////////////////////////////////////////9Or7hAAAAAEHRSTlMAESIzRFVmd4iZqrvM3e7/dpUBFQAAAL1JREFUeAFjGAVgEHsVh8T9/6RKxH/FKsza9f//igBMcY3/YNCELs4BEf//vwFVnOk8TOKPAoqE7v//f1sVmCLu//9/CUXD/f9/C0AMdiADWQvP//+LICyt//8PIEn0//8FY67//wPJpP//F8DYXP//I8ziQDIYaB3Cxfz/vyO01///gAik/xcQErz/EUHWj+xfDiTb1/9HCjxWhAsZkB0CciKSBHIwkCsRCwtuZABJACRI/MVlFK50NwqwAgAGsre9i7ZqwAAAAABJRU5ErkJggg==]=],
}
local IconVector = {
    -- Lucide-style activity and signal paths for the profile metrics.
    ["activity"] = {{2,12,6,12,9,3,15,21,18,12,22,12}},
    ["signal"] = {{2,20,2,20},{7,20,7,16},{12,20,12,12},{17,20,17,8},{22,20,22,4}},
    -- Native line fallbacks for the three new Home utility icons.
    ["clock"] = {{12,2,15.83,2.76,19.07,4.93,21.24,8.17,22,12,21.24,15.83,19.07,19.07,15.83,21.24,12,22,8.17,21.24,4.93,19.07,2.76,15.83,2,12,2.76,8.17,4.93,4.93,8.17,2.76,12,2},{12,6,12,12,16,14}},
    ["save"] = {{19,21,5,21,3,19,3,5,5,3,17,3,21,7,21,19,19,21},{7,3,7,9,15,9,15,3},{7,21,7,13,17,13,17,21}},
    ["lock"] = {{5,11,19,11,21,13,21,20,19,22,5,22,3,20,3,13,5,11},{7,11,7,7,7.4,5.1,8.5,3.6,10.1,2.4,12,2,13.9,2.4,15.5,3.6,16.6,5.1,17,7,17,11},{12,15,12,18}},
    -- Lucide v0.456.0: minus, plus, x, circle-check (native lightweight paths).
    ["minus"] = {{5,12,19,12}},
    ["plus"] = {{5,12,19,12},{12,5,12,19}},
    ["x"] = {{18,6,6,18},{6,6,18,18}},
    ["circle-check"] = {{9,12,11,14,15,10}},
    ["house"] = {{15,21,15,13,14,12,9.29,12.29,9,21},{3,10,3.71,8.47,10.71,2.47,11.54,2.05,13.29,2.47,20.81,9.16,20.73,20.01,19,21,3.99,20.73,3,19,3,10}},
    ["contact-round"] = {{16,2,16,4},{17.92,22,17.44,19.67,16.16,17.76,14.25,16.47,11.92,16,9.58,16.47,7.67,17.76,6.39,19.67,5.92,22},{8,2,8,4},{16,12,15.06,14.57,12.7,15.94,10,15.46,8.24,13.37,8,12,8.94,9.43,11.31,8.06,14,8.54,15.76,10.63,16,12},{5,4,19,4,20.73,4.99,21,20,20.01,21.73,5,22,3.27,21.01,3,6,3.27,4.99,5,4}},
    ["user-round-cog"] = {{2,21,2.87,17.38,5.28,14.54,8.72,13.1,12.43,13.38},{15,8,14.82,9.35,13.41,11.65,11.02,12.9,9.66,12.99,7.12,12.09,6.12,11.16,5.05,8.68,5.41,6.01,6.12,4.85,7.12,3.92,9.66,3.01,11.02,3.11,13.41,4.35,14.82,6.65,15,8},{21,18,20.7,19.3,18.67,20.93,16.13,20.35,15,18,15.3,16.7,17.33,15.08,19.87,15.66,21,18},{19.5,14.3,19.1,15.2},{16.9,20.8,16.5,21.7},{21.7,19.5,20.8,19.1},{15.2,16.9,14.3,16.5},{21.7,16.5,20.8,16.9},{15.2,19.1,14.3,19.5},{19.5,21.7,19.1,20.8},{16.9,15.2,16.5,14.3}},
    ["eye"] = {{2.06,12.35,3.32,9.41,6.02,6.82,9.45,5.31,12,5,14.55,5.31,17.98,6.82,20.69,9.41,22,12,20.69,14.59,17.98,17.18,14.55,18.69,12,19,9.45,18.69,6.02,17.18,3.32,14.59,2.06,12.35},{15,12,14.7,13.3,12.67,14.93,10.13,14.35,9,12,9.3,10.7,11.33,9.07,13.87,9.65,15,12}},
    ["swords"] = {{14.5,17.5,3,6,3,3,6,3,17.5,14.5},{13,19,19,13},{16,16,20,20},{19,21,21,19},{14.5,6.5,18,3,21,3,21,6,17.5,9.5},{5,14,9,18},{7,17,4,20},{3,19,5,21}},
    ["shield"] = {{20,13,19.13,16.86,16.83,19.61,12.34,21.95,9.27,20.94,6.27,18.81,4.4,15.71,4,13,4.29,5.29,8.22,4.21,12,2,15.79,4.21,19.71,5.29,20,13}},
    ["refresh-cw"] = {{3,12,3.32,9.61,4.88,6.5,7.46,4.23,9.61,3.32,12,3,15.64,3.72,17.79,4.93,21,8},{21,3,21,8,16,8},{21,12,20.68,14.39,19.13,17.5,16.54,19.77,14.39,20.68,12,21,8.37,20.28,6.21,19.07,3,16},{8,16,3,16,3,21}},
    ["server"] = {{4,2,21.01,2.27,22,4,21.73,9.01,20,10,2.99,9.73,2,8,2,4,2.27,2.99,4,2},{4,14,21.01,14.27,22,16,21.73,21.01,20,22,2.99,21.73,2,20,2,16,2.27,14.99,4,14},{6,6,6.01,6},{6,18,6.01,18}},
    ["users-round"] = {{18,21,17.59,18.47,15.66,15.34,12.53,13.41,10,13,7.47,13.41,4.34,15.34,2.41,18.47,2,21},{15,8,14.82,9.35,13.41,11.65,11.02,12.9,9.66,12.99,7.12,12.09,6.12,11.16,5.05,8.68,5.41,6.01,6.12,4.85,7.12,3.92,9.66,3.01,11.02,3.11,13.41,4.35,14.82,6.65,15,8},{22,20,21.06,15.91,18,12,19.53,10.11,19.99,7.73,19.27,5.41,17.55,3.7}},
    ["info"] = {{22,12,21.61,14.76,19.66,18.43,16.38,20.99,12.35,21.99,8.25,21.27,5.84,19.88,3.17,16.7,2.02,12.7,2.6,8.58,4.81,5.05,8.25,2.73,12.35,2.01,16.38,3.01,19.66,5.57,21.61,9.24,22,12},{12,16,12,12},{12,8,12.01,8}},
    ["globe"] = {{22,12,21.61,14.76,19.66,18.43,16.38,20.99,12.35,21.99,8.25,21.27,5.84,19.88,3.17,16.7,2.02,12.7,2.6,8.58,4.81,5.05,8.25,2.73,12.35,2.01,16.38,3.01,19.66,5.57,21.61,9.24,22,12},{12,2,9.24,6.14,8.44,8.43,8,12,8.44,15.57,9.24,17.86,12,22,14.77,17.86,15.56,15.57,16,12,15.56,8.43,14.77,6.14,12,2},{2,12,22,12}},
    ["user-round"] = {{17,8,16.82,9.35,15.41,11.65,13.02,12.9,11.66,12.99,9.12,12.09,8.12,11.16,7.05,8.68,7.41,6.01,8.12,4.85,9.12,3.92,11.66,3.01,13.02,3.11,15.41,4.35,16.82,6.65,17,8},{20,21,19.59,18.47,17.66,15.34,14.53,13.41,12,13,9.47,13.41,6.34,15.34,4.41,18.47,4,21}},
    ["box"] = {{21,8,20,6.27,13,2.27,11,2.27,3.27,7,3.27,17,11,21.73,13,21.73,20.73,17,21,8},{3.3,7,12,12,20.7,7},{12,22,12,12}},
    ["layers"] = {{12.83,2.18,11.17,2.18,2.6,6.08,2,7,2.17,7.54,12.01,12,21.85,7.55,22.02,7.01,21.42,6.09,12.83,2.18},{22,17.65,12,21.99,2,17.65},{22,12.65,12,16.99,2,12.65}},
    ["search"] = {{19,11,18.52,13.74,17.13,16.14,13.74,18.52,11,19,8.26,18.52,5.86,17.13,3.48,13.74,3,11,3.48,8.26,4.87,5.86,8.26,3.48,11,3,13.74,3.48,17.13,5.86,18.52,8.26,19,11},{21,21,16.7,16.7}},
    ["maximize"] = {{8,3,3.99,3.27,3,5,3,8},{21,8,20.73,3.99,19,3,16,3},{3,16,3.27,20.01,5,21,8,21},{16,21,20.01,20.73,21,19,21,16}},
    ["shirt"] = {{20.38,3.46,16,2,15.23,4.36,13.26,5.8,12,6,9.64,5.23,8.2,3.26,8,2,2.82,3.96,2.28,5.69,2.86,9.16,3.85,10,6,10,6,20,6.99,21.73,16,22,17.73,21.01,18,10,20.8,9.76,21.72,5.69,21.65,4.75,20.38,3.46}},
    ["smile"] = {{22,12,21.61,14.76,19.66,18.43,16.38,20.99,12.35,21.99,8.25,21.27,5.84,19.88,3.17,16.7,2.02,12.7,2.6,8.58,4.81,5.05,8.25,2.73,12.35,2.01,16.38,3.01,19.66,5.57,21.61,9.24,22,12},{8,14,10.32,15.69,12,16,13.68,15.69,16,14},{9,9,9.01,9},{15,9,15.01,9}},
    ["arrow-up"] = {{5,12,12,5,19,12},{12,19,12,5}},
    ["arrow-down"] = {{12,5,12,19},{19,12,12,19,5,12}},
    ["camera"] = {{14.5,4,9.5,4,7,7,4,7,2.27,7.99,2,18,2.99,19.73,20,20,21.73,19.01,21.73,7.99,20,7,17,7,14.5,4},{15,13,14.7,14.3,12.67,15.93,10.13,15.35,9,13,9.3,11.7,11.33,10.07,13.87,10.66,15,13}},
    ["heart"] = {{19,14,21.37,11.01,22,8.5,21.44,6.08,18.92,3.56,15.27,3.1,12,5,9.85,3.44,6.24,3.15,4.06,4.21,2.56,6.08,2,8.5,3.3,12.1,12,21,19,14}},
    ["play"] = {{6,3,20,12,6,21,6,3}},
    ["bot"] = {{12,8,12,4,8,4},{6,8,19.01,8.27,20,10,19.73,19.01,18,20,4.99,19.73,4,18,4,10,4.27,8.99,6,8},{2,14,4,14},{20,14,22,14},{15,13,15,15},{9,13,9,15}},
    ["sun"] = {{16,12,15.06,14.57,12.7,15.94,10,15.46,8.24,13.37,8,12,8.94,9.43,11.31,8.06,14,8.54,15.76,10.63,16,12},{12,2,12,4},{12,20,12,22},{4.93,4.93,6.34,6.34},{17.66,17.66,19.07,19.07},{2,12,4,12},{20,12,22,12},{6.34,17.66,4.93,19.07},{19.07,4.93,17.66,6.34}},
    ["chevron-down"] = {{6,9,12,15,18,9}},
    ["check"] = {{20,6,9,17,4,12}},
    ["chevron-right"] = {{9,18,15,12,9,6}},
    ["feather"] = {{12.67,19,14.09,18.41,20.24,12.24,21.56,10.25,22,8,21.56,5.74,20.24,3.75,18.25,2.43,14.85,2.1,12.69,2.98,5.15,10.56,5.29,18.71,12.67,19},{16,8,2,22},{17.5,15,9,15}},
    ["person-standing"] = {{13,5,12,6,11,5,12,4,13,5},{9,20,12,14,15,20},{6,8,12,10,18,8},{12,10,12,14}},
    ["hanger"] = {{14,6,13.01,4.27,10.99,4.27,10,6,10.5,8.25,11.99,10,19.96,14.43,20.99,16.18,20.72,18.01,18.99,19,3.98,18.73,2.99,17,3.27,15.16,11.99,10}},
    ["run"] = {{12,4,13,5,14,4,13,3,12,4},{4,17,9,18,9.75,16.5},{15,21,15,17,11,14,12,8},{7,12,7,9,12,8,15,11,18,12}},
    ["walk"] = {{12,4,13,5,14,4,13,3,12,4},{7,21,10,17},{16,21,14,17,11,14,12,8},{6,12,8,9,12,8,15,11,18,12}},
    ["man"] = {{10,16,10,21},{14,16,14,21},{9,9,15,9,14,16,10,16,9,9},{5,11,7,9.5,9,9},{19,11,17,9.5,15,9},{10,4,10.27,5.01,12,6,13.01,5.73,14,4,13.73,2.99,12,2,10.99,2.27,10,4}},
    ["wall"] = {{4,6,4.27,4.99,6,4,19.01,4.27,20,6,19.73,19.01,18,20,4.99,19.73,4,18,4,6},{4,8,20,8},{20,12,4,12},{4,16,20,16},{9,4,9,8},{14,8,14,12},{8,12,8,16},{16,12,16,16},{11,16,11,20}},
    ["pants"] = {{12,19,16.44,19,17.04,18.44,17.8,3.19,6.2,3.19,6.97,20.43,7.57,21,11.4,21,12,20.4,12,8}},
    ["hat"] = {{7,17,7.11,13.74,7.96,11.47,9.49,9.65,11.56,8.44,14,8,16.44,8.44,18.51,9.65,20.56,12.56,21,17,7,17},{7,17,2,17},{14,6.01,14.01,5.999}},
}
local iconUris, iconFailed = {}, {}
local function decodeIcon(data)
    local chars="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local map={}; for i=1,#chars do map[chars:sub(i,i)]=i-1 end
    local parts={}
    for i=1,#data,4 do
        local a,b,c,d=map[data:sub(i,i)] or 0,map[data:sub(i+1,i+1)] or 0,map[data:sub(i+2,i+2)] or 0,map[data:sub(i+3,i+3)] or 0
        local v=a*262144+b*4096+c*64+d
        local x,y,z=math.floor(v/65536)%256,math.floor(v/256)%256,v%256
        if data:sub(i+2,i+2)=="=" then parts[#parts+1]=string.char(x)
        elseif data:sub(i+3,i+3)=="=" then parts[#parts+1]=string.char(x,y)
        else parts[#parts+1]=string.char(x,y,z) end
    end
    return table.concat(parts)
end
local function getIconUri(key)
    if iconUris[key] then return iconUris[key] end
    if iconFailed[key] then return nil end
    local writer, getter=writefile,getcustomasset or getsynasset
    if type(writer)=="function" and type(getter)=="function" and IconPNG[key] then
        local ok,uri=pcall(function()
            local filename="HorizonUI2_Icon27_"..key..".png"
            writer(filename,decodeIcon(IconPNG[key]))
            return getter(filename)
        end)
        if ok and type(uri)=="string" and uri~="" then iconUris[key]=uri; return uri end
    end
    iconFailed[key]=true
    return nil
end
-- Compact native fallback using the same library contours.
local function drawFallback(holder,key,size,ink)
    local k=size/24; local width=2*k
    -- A native circular outline replaces the old polygon when PNG is unavailable.
    if key=="circle-check" then
        local ring=new("Frame",{Name="CircularOutline",AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(20*k,20*k),BackgroundTransparency=1,BorderSizePixel=0,Active=false,ZIndex=holder.ZIndex},holder)
        new("UICorner",{CornerRadius=UDim.new(.5,0)},ring)
        new("UIStroke",{Color=ink,Thickness=width,Transparency=0,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},ring)
    end
    for _,path in ipairs(IconVector[key] or {}) do
        for i=1,#path-2,2 do
            local x1,y1,x2,y2=path[i],path[i+1],path[i+2],path[i+3]
            local dx,dy=(x2-x1)*k,(y2-y1)*k
            local f=new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromOffset((x1+x2)*k/2,(y1+y2)*k/2),Size=UDim2.fromOffset(math.sqrt(dx*dx+dy*dy)+width,width),Rotation=math.deg(math.atan2(dy,dx)),BackgroundColor3=ink,BorderSizePixel=0,Active=false,ZIndex=holder.ZIndex},holder)
            corner(f,width/2)
        end
    end
end

-- Build the main window before loading optional icons.
local iconQueue={}
local iconWorker=false
local function libraryIcon(parent,key,position,size,name,tint,anchor)
    local ink=tint or C.text
    local holder=new("Frame",{Name=name or tostring(key).."Icon",Position=position,Size=UDim2.fromOffset(size,size),AnchorPoint=anchor or Vector2.new(0,0),BackgroundTransparency=1,BorderSizePixel=0,Active=false,ZIndex=parent.ZIndex+1},parent)
    iconQueue[#iconQueue+1]={holder=holder,key=key,size=size,ink=ink}
    if not iconWorker then
        iconWorker=true
        task.defer(function()
            local i=1
            while i<=#iconQueue do
                local item=iconQueue[i]
                local ok,err=pcall(function()
                    if not item.holder.Parent then return end
                    local uri=item.key and getIconUri(item.key)
                    if not item.holder.Parent then return end
                    if uri then
                        local loaded=pcall(function()
                            new("ImageLabel",{Name="LibraryPNG",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,Image=uri,ImageColor3=item.ink,ScaleType=Enum.ScaleType.Fit,Active=false,ZIndex=item.holder.ZIndex},item.holder)
                        end)
                        if loaded then return end
                    end
                    drawFallback(item.holder,item.key,item.size,item.ink)
                end)
                if not ok then warn("[HORIZON UI 2.0] Optional icon: "..tostring(err)) end
                i=i+1
                if i%5==0 then task.wait() end
            end
            iconQueue={}
            iconWorker=false
        end)
    end
    return holder
end
-- v31: Danger Accent controls and Horizon Progress notifications.
-- Render simple Lucide paths synchronously; no additional assets are needed.
local function nativeSymbol(parent,key,size,name,tint)
    local holder=new("Frame",{Name=name,AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(size,size),BackgroundTransparency=1,BorderSizePixel=0,Active=false,ZIndex=parent.ZIndex+1},parent)
    drawFallback(holder,key,size,tint or C.text)
    return holder
end
do
    nativeSymbol(close,"x",24,"CloseIcon")
    nativeSymbol(minimize,"minus",24,"MinimizeIcon")
end
local showToast
do
    local activeToast
    showToast=function(message)
        if not window.Parent or collapsed then return end
        if activeToast and activeToast.Parent then activeToast:Destroy() end
        local green=Color3.fromRGB(119,214,150)
        local toast=new("Frame",{Name="HorizonProgressToast",AnchorPoint=Vector2.new(.5,1),Position=UDim2.new(.5,0,1,-14),Size=UDim2.fromOffset(320,66),BackgroundColor3=C.slot,BorderSizePixel=0,Active=false,ZIndex=80},window)
        activeToast=toast
        corner(toast,8)
        stroke(toast,C.line,.35,1)
        local iconHost=new("Frame",{Position=UDim2.fromOffset(14,12),Size=UDim2.fromOffset(32,32),BackgroundTransparency=1,BorderSizePixel=0,Active=false,ZIndex=81},toast)
        -- v32: original Lucide PNG, with a smooth native fallback until loaded.
        local fallback=nativeSymbol(iconHost,"circle-check",30,"SuccessIcon",green)
        local uri=getIconUri("circle-check")
        if uri then
            local ok,image=pcall(function()
                return new("ImageLabel",{Name="SuccessLibraryPNG",AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(30,30),BackgroundTransparency=1,BorderSizePixel=0,Image=uri,ImageColor3=green,ImageTransparency=0,ScaleType=Enum.ScaleType.Fit,Active=false,Visible=false,ZIndex=iconHost.ZIndex+1},iconHost)
            end)
            if ok and image then
                local function revealLoadedIcon()
                    if image.Parent and image.IsLoaded then
                        fallback.Visible=false
                        image.Visible=true
                    end
                end
                image:GetPropertyChangedSignal("IsLoaded"):Connect(revealLoadedIcon)
                revealLoadedIcon()
            end
        end
        new("Frame",{Name="IconDivider",Position=UDim2.fromOffset(56,12),Size=UDim2.fromOffset(2,32),BackgroundColor3=Color3.fromRGB(133,135,142),BorderSizePixel=0,Active=false,ZIndex=81},toast)
        new("TextLabel",{Name="Message",Position=UDim2.fromOffset(70,0),Size=UDim2.new(1,-82,0,56),BackgroundTransparency=1,Text=message,TextColor3=C.text,Font=Enum.Font.GothamMedium,TextSize=23,TextScaled=false,TextTruncate=Enum.TextTruncate.AtEnd,TextXAlignment=Enum.TextXAlignment.Left,Active=false,ZIndex=81},toast)
        local track=new("Frame",{Name="ProgressTrack",Position=UDim2.new(0,8,1,-7),Size=UDim2.new(1,-16,0,3),BackgroundColor3=Color3.fromRGB(65,67,73),BorderSizePixel=0,Active=false,ZIndex=81,ClipsDescendants=true},toast)
        corner(track,2)
        local fill=new("Frame",{Name="ProgressFill",Size=UDim2.fromScale(0,1),BackgroundColor3=green,BorderSizePixel=0,Active=false,ZIndex=82},track)
        corner(fill,2)
        local fadeTargets={}
        local function addTarget(object,property)
            fadeTargets[#fadeTargets+1]={object=object,property=property,alpha=object[property]}
        end
        addTarget(toast,"BackgroundTransparency")
        for _,object in ipairs(toast:GetDescendants()) do
            if object:IsA("UIStroke") then
                addTarget(object,"Transparency")
            elseif object:IsA("ImageLabel") then
                addTarget(object,"ImageTransparency")
            elseif object:IsA("TextLabel") then
                addTarget(object,"TextTransparency")
                if object.BackgroundTransparency<1 then addTarget(object,"BackgroundTransparency") end
            elseif object:IsA("Frame") and object.BackgroundTransparency<1 then
                addTarget(object,"BackgroundTransparency")
            end
        end
        local function fade(visible,duration)
            for _,target in ipairs(fadeTargets) do
                if target.object.Parent then
                    TweenService:Create(target.object,TweenInfo.new(duration,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{[target.property]=visible and target.alpha or 1}):Play()
                end
            end
        end
        for _,target in ipairs(fadeTargets) do target.object[target.property]=1 end
        fade(true,.20)
        task.delay(.20,function()
            if not toast.Parent or activeToast~=toast then return end
            local progress=TweenService:Create(fill,TweenInfo.new(2,Enum.EasingStyle.Linear),{Size=UDim2.fromScale(1,1)})
            progress.Completed:Once(function(state)
                if state~=Enum.PlaybackState.Completed or not toast.Parent or activeToast~=toast then return end
                fade(false,.25)
                task.delay(.25,function()
                    if toast.Parent then toast:Destroy() end
                    if activeToast==toast then activeToast=nil end
                end)
            end)
            progress:Play()
        end)
    end
end
local navLibrary={"house","contact-round","user-round-cog","eye","swords","shield"}
local function drawIcon(parent,index)
    return libraryIcon(parent,navLibrary[index],UDim2.new(0,10,.5,-19),38,"VectorIcon")
end
-- Home page: isolated from navigation and gameplay logic.
local home = new('ScrollingFrame',{Name='HomePage',Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=4,CanvasSize=UDim2.fromOffset(0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y},content)
local muted=Color3.fromRGB(174,176,184)
local function label(p,t,x,y,w,h,s,b)
 return new('TextLabel',{Position=UDim2.fromOffset(x,y),Size=UDim2.new(w,0,0,h),BackgroundTransparency=1,Text=t,TextColor3=b and C.text or muted,Font=b and Enum.Font.GothamBold or Enum.Font.Gotham,TextSize=s,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd},p)
end
local function panel(p,x,y,w,h,button)
 local f=new(button and 'TextButton' or 'Frame',{Position=UDim2.new(x,12,y,12),Size=UDim2.new(w,-24,0,h),BackgroundColor3=C.slot,BorderSizePixel=0},p)
 if button then f.Text=''; f.AutoButtonColor=true end
 corner(f,10); stroke(f,C.line,.65,1); return f
end
-- Unified welcome and player profile (same footprint as the two previous panels).
local profile=panel(home,0,0,1,268,false)
profile.Name='PlayerProfile'
profile:FindFirstChildOfClass('UIStroke').Transparency=.35
local avatar=new('ImageLabel',{Position=UDim2.fromOffset(18,74),Size=UDim2.fromOffset(120,120),BackgroundColor3=C.side,BorderSizePixel=0,Image=''},profile)
corner(avatar,60); stroke(avatar,C.line,.25,2)
do
    local glyph=libraryIcon(profile,'house',UDim2.fromOffset(26,17),36,'WelcomeIcon')
    local separator=new('Frame',{Name='WelcomeIconDivider',Position=UDim2.fromOffset(74,17),Size=UDim2.fromOffset(2,36),BackgroundColor3=Color3.fromRGB(143,145,152),BackgroundTransparency=.08,BorderSizePixel=0},profile)
    local greeting=label(profile,'Добро пожаловать',88,10,1,50,26,true)
    greeting.Name='WelcomeTitle'
    greeting.Size=UDim2.new(1,-100,0,50)
    local displayName=label(profile,player.DisplayName,164,88,1,44,34,true)
    displayName.Size=UDim2.new(1,-176,0,44)
    local username=label(profile,'@'..player.Name,164,135,1,32,23,false)
    username.Size=UDim2.new(1,-176,0,32)
    -- One compact, single-line metrics strip inside the existing profile card.
    -- Preview placeholders only: live telemetry will be connected separately.
    local metrics=new('Frame',{Name='ProfileMetrics',Position=UDim2.fromOffset(12,206),Size=UDim2.new(1,-24,0,48),BackgroundColor3=Color3.fromRGB(57,58,64),BorderSizePixel=0},profile)
    corner(metrics,10); stroke(metrics,C.line,.50,1)
    local definitions={
        {id='FPS',icon='activity',caption='FPS  —',short='FPS —',width=108},
        {id='Ping',icon='signal',caption='Пинг  — мс',short='Пинг —',width=146},
        {id='Session',icon='clock',caption='Сессия  —:—:—',short='—:—:—',width=174},
    }
    local metricRows={}
    for i,def in ipairs(definitions) do
        local cell=new('Frame',{Name=def.id,Position=UDim2.fromScale((i-1)/3,0),Size=UDim2.fromScale(1/3,1),BackgroundTransparency=1,BorderSizePixel=0},metrics)
        local group=new('Frame',{Name='MetricContent',AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(def.width,32),BackgroundTransparency=1,BorderSizePixel=0},cell)
        local metricIcon=libraryIcon(group,def.icon,UDim2.fromOffset(0,3),26,def.id..'Icon')
        local metricIconScale=new('UIScale',{Scale=1},metricIcon)
        local metricText=label(group,def.caption,36,0,1,32,18,false)
        metricText.Name='Value'
        metricText.TextColor3=C.text
        metricText.Size=UDim2.new(1,-36,1,0)
        metricRows[i]={group=group,icon=metricIcon,iconScale=metricIconScale,text=metricText,definition=def}
        if i<3 then
            new('Frame',{Name='MetricDivider'..i,AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(i/3,.5),Size=UDim2.fromOffset(1,24),BackgroundColor3=C.line,BackgroundTransparency=.20,BorderSizePixel=0},metrics)
        end
    end
    local function fitMetrics(narrow)
        for _,item in ipairs(metricRows) do
            item.group.Size=UDim2.fromOffset(narrow and 64 or item.definition.width,32)
            item.icon.Position=UDim2.fromOffset(0,narrow and 9 or 3)
            item.iconScale.Scale=narrow and .54 or 1
            item.text.Position=UDim2.fromOffset(narrow and 18 or 36,0)
            item.text.Size=UDim2.new(1,narrow and -18 or -36,1,0)
            item.text.TextSize=narrow and 10 or 18
            item.text.Text=narrow and item.definition.short or item.definition.caption
        end
    end
    local glyphScale=new('UIScale',{Scale=1},glyph)
    local function fitProfile()
        local narrow=window.Size.X.Offset<650
        glyph.Position=UDim2.fromOffset(narrow and 12 or 26,narrow and 18 or 17)
        glyphScale.Scale=narrow and .67 or 1
        separator.Position=UDim2.fromOffset(narrow and 44 or 74,narrow and 18 or 17)
        separator.Size=UDim2.fromOffset(2,narrow and 25 or 36)
        greeting.Position=UDim2.fromOffset(narrow and 54 or 88,10)
        greeting.Size=UDim2.new(1,narrow and -64 or -100,0,narrow and 42 or 50)
        greeting.TextSize=narrow and 16 or 26
        avatar.Position=UDim2.fromOffset(narrow and 12 or 18,narrow and 82 or 74)
        avatar.Size=UDim2.fromOffset(narrow and 72 or 120,narrow and 72 or 120)
        displayName.Position=UDim2.fromOffset(narrow and 94 or 164,narrow and 85 or 88)
        displayName.Size=UDim2.new(1,narrow and -104 or -176,0,narrow and 32 or 44)
        displayName.TextSize=narrow and 19 or 34
        username.Position=UDim2.fromOffset(narrow and 94 or 164,narrow and 120 or 135)
        username.Size=UDim2.new(1,narrow and -104 or -176,0,narrow and 26 or 32)
        username.TextSize=narrow and 14 or 23
        fitMetrics(narrow)
    end
    local profileResize=window:GetPropertyChangedSignal('Size'):Connect(fitProfile)
    profile.Destroying:Connect(function() profileResize:Disconnect() end)
    fitProfile()
end
task.spawn(function() local ok,url=pcall(function() return Players:GetUserThumbnailAsync(player.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size150x150) end); if ok and avatar.Parent then avatar.Image=url end end)
local homeLibrary={refresh="refresh-cw",server="server",users="users-round",info="info",globe="globe"}
local function homeIcon(parent,kind,x,y,size)
    return libraryIcon(parent,homeLibrary[kind],UDim2.new(x,0,0,y),size,kind.."Icon",nil,Vector2.new(x==.5 and .5 or 0,0))
end
local function action(x,title,sub,kind)
 local b=panel(home,x,0,.5,76,true); b.Position=UDim2.new(x,12,0,292)
 local glyph=homeIcon(b,kind,0,16,44); glyph.Position=UDim2.fromOffset(14,16)
 new('Frame',{Position=UDim2.fromOffset(70,12),Size=UDim2.fromOffset(1,52),BackgroundColor3=C.line,BackgroundTransparency=.35,BorderSizePixel=0},b)
 local t=label(b,title,82,8,1,30,23,true); t.Size=UDim2.new(1,-90,0,30)
 local d=label(b,sub,82,38,1,26,17,false); d.Size=UDim2.new(1,-90,0,26)
 return b
end
local rejoin=action(0,'Переподключиться','Зайти на этот же сервер','refresh')
local hop=action(.5,'Другой сервер','Найти новый сервер','server')
local online=panel(home,0,0,.5,86,false); online.Position=UDim2.fromOffset(12,380)
local oi=homeIcon(online,'users',0,23,40); oi.Position=UDim2.fromOffset(12,23)
label(online,'Игроки онлайн',64,5,.72,32,23,true)
local count=label(online,'',64,37,.72,40,32,true)
local function updateCount() if count.Parent then count.Text=tostring(#Players:GetPlayers()) end end
updateCount()
local joined=Players.PlayerAdded:Connect(function() task.defer(updateCount) end)
local left=Players.PlayerRemoving:Connect(function() task.defer(updateCount) end)
gui.Destroying:Connect(function() joined:Disconnect(); left:Disconnect() end)
local info=panel(home,.5,0,.5,86,true); info.Position=UDim2.new(.5,12,0,380)
local ii=homeIcon(info,'info',0,23,40); ii.Position=UDim2.fromOffset(12,23)
label(info,'Информация  ›',64,5,.72,34,25,true)
label(info,'Версия и обновления',64,42,.72,30,19,false)
local overlay=new('Frame',{Name='InformationOverlay',Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=.35,Visible=false,Active=true,ZIndex=20},window)
local modal=new('Frame',{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.new(.82,0,.78,0),BackgroundColor3=C.outer,BorderSizePixel=0,ZIndex=21},overlay)
corner(modal,14); stroke(modal,C.line,.25,1)
local heading=label(modal,'Информация',20,10,.7,50,28,true); heading.ZIndex=22
local dismiss=new('TextButton',{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-12,0,12),Size=UDim2.fromOffset(44,44),Text='×',TextSize=28,TextColor3=C.text,BackgroundColor3=C.slot,ZIndex=22},modal); corner(dismiss,8)
local history=new('ScrollingFrame',{Position=UDim2.fromOffset(20,76),Size=UDim2.new(1,-40,1,-96),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=5,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.fromOffset(0,0),ZIndex=22},modal)
local entry=label(history,'v2.0 — предварительный макет',0,0,1,40,23,true); entry.ZIndex=23
local details=label(history,'• Новая боковая навигация\n• Контурные иконки\n• Анимация Soft Press\n• Главная страница и окно информации',0,48,1,180,21,false); details.TextWrapped=true; details.TextTruncate=Enum.TextTruncate.None; details.TextYAlignment=Enum.TextYAlignment.Top; details.ZIndex=23
local modalScale=new('UIScale',{Scale=1},modal)
-- Home language selector: visual preview only; no localization or persistence yet.
do
    local language=panel(home,0,0,1,76,true)
    language.Name='LanguageButton'
    language.Position=UDim2.fromOffset(12,478)
    local glyph=homeIcon(language,'globe',0,18,40)
    glyph.Position=UDim2.fromOffset(12,18)
    local title=label(language,'Язык интерфейса',64,5,1,32,23,true)
    title.Size=UDim2.new(1,-94,0,32)
    local value=label(language,'🇷🇺 Русский',64,39,1,28,19,false)
    value.Size=UDim2.new(1,-94,0,28)
    local arrow=label(language,'›',0,0,1,76,29,false)
    arrow.Position=UDim2.new(1,-30,0,0)
    arrow.Size=UDim2.fromOffset(22,76)
    arrow.TextXAlignment=Enum.TextXAlignment.Center

    -- Reuse the existing modal backdrop so tab switching and minimizing
    -- dismiss either dialog through the original overlay cleanup.
    local picker=new('Frame',{Name='LanguagePicker',AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.new(.82,0,.84,0),BackgroundColor3=C.outer,BorderSizePixel=0,ZIndex=21,Visible=false},overlay)
    new('UISizeConstraint',{MaxSize=Vector2.new(520,510)},picker)
    corner(picker,14); stroke(picker,C.line,.25,1)
    local pickerTitle=label(picker,'Язык интерфейса',20,10,1,48,26,true)
    pickerTitle.Size=UDim2.new(1,-78,0,48); pickerTitle.ZIndex=22
    local x=new('TextButton',{Name='CloseLanguage',AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-12,0,12),Size=UDim2.fromOffset(44,44),Text='×',TextSize=28,TextColor3=C.text,BackgroundColor3=C.slot,BorderSizePixel=0,ZIndex=22},picker); corner(x,8)
    local pickerScale=new('UIScale',{Scale=1},picker)
    -- Native language names with representative country flags.
    local options={
        '🇷🇺 Русский','🇬🇧 English','🇪🇸 Español (Latinoamérica)','🇧🇷 Português (Brasil)',
        '🇫🇷 Français (France)','🇩🇪 Deutsch (Deutschland)','🇵🇱 Polski','🇹🇷 Türkçe',
        '🇯🇵 日本語','🇰🇷 한국어','🇨🇳 中文（简体）','🇧🇾 Беларуская',
        '🇮🇩 Bahasa Indonesia','🇹🇭 ไทย','🇸🇦 العربية','🇮🇹 Italiano','🇵🇭 Filipino','🇳🇱 Nederlands',
        '🇻🇳 Tiếng Việt','🇮🇳 हिन्दी',
    }
    local list=new('ScrollingFrame',{Name='LanguageOptionsScroll',Position=UDim2.fromOffset(16,70),Size=UDim2.new(1,-32,1,-122),BackgroundTransparency=1,BorderSizePixel=0,CanvasSize=UDim2.fromOffset(0,#options*66-10),ScrollingDirection=Enum.ScrollingDirection.Y,ScrollBarThickness=4,ScrollBarImageColor3=C.line,ClipsDescendants=true,ZIndex=22},picker)
    local rows,marks={},{}
    local selected=1
    local function refresh()
        for i,row in ipairs(rows) do
            row.BackgroundColor3=i==selected and Color3.fromRGB(75,77,84) or C.slot
            marks[i].Visible=i==selected
        end
        value.Text=options[selected]
    end
    for i,name in ipairs(options) do
        local row=new('TextButton',{Name='LanguageOption'..i,Position=UDim2.fromOffset(0,(i-1)*66),Size=UDim2.new(1,-8,0,56),Text='',AutoButtonColor=false,BackgroundColor3=C.slot,BorderSizePixel=0,ZIndex=23},list)
        corner(row,8); stroke(row,C.line,.65,1)
        local caption=label(row,name,16,0,1,56,24,true)
        caption.Size=UDim2.new(1,-66,0,56); caption.ZIndex=24
        caption.TextWrapped=true; caption.TextTruncate=Enum.TextTruncate.None
        caption.TextScaled=true; new('UITextSizeConstraint',{MinTextSize=12,MaxTextSize=24},caption)
        local mark=libraryIcon(row,'check',UDim2.new(1,-39,0,16),24,'LanguageCheck')
        rows[i]=row; marks[i]=mark
        row.Activated:Connect(function() if selected==i then return end; selected=i; refresh(); showToast('Язык выбран') end)
    end
    local note=label(picker,'Предпросмотр выбора языка',16,0,1,40,18,false)
    note.Position=UDim2.new(0,16,1,-46)
    note.Size=UDim2.new(1,-32,0,40); note.TextWrapped=true; note.TextTruncate=Enum.TextTruncate.None; note.ZIndex=22
    local function show(target,scale)
        modal.Visible=target==modal; picker.Visible=target==picker
        overlay.Visible=true; scale.Scale=.94
        if target==picker then
            list.CanvasPosition=Vector2.new(0,math.max(0,math.min((selected-1)*66,#options*66-10-list.AbsoluteWindowSize.Y)))
        end
        TweenService:Create(scale,TweenInfo.new(.18),{Scale=1}):Play()
    end
    refresh()
    language.Activated:Connect(function() show(picker,pickerScale) end)
    info.Activated:Connect(function() show(modal,modalScale) end)
    x.Activated:Connect(function() overlay.Visible=false end)
    dismiss.Activated:Connect(function() overlay.Visible=false end)
end
local function previewNotice(b) local original=b.BackgroundColor3; b.BackgroundColor3=Color3.fromRGB(75,77,84); task.delay(.2,function() if b.Parent then b.BackgroundColor3=original end end) end
rejoin.Activated:Connect(function() previewNotice(rejoin) end)
hop.Activated:Connect(function() previewNotice(hop) end)

-- Avatar page: visual-only layout, independent of the existing Home page.
-- Sample rows and a native ViewportFrame mannequin; no gameplay or inventory actions.
local avatarPage=new('Frame',{Name='AvatarPage',Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=false,ClipsDescendants=true},content)
local avatarCanvas=new('Frame',{Name='AvatarCanvas',AnchorPoint=Vector2.new(.5,0),Position=UDim2.fromScale(.5,0),Size=UDim2.fromOffset(720,595),BackgroundTransparency=1},avatarPage)
local avatarScale=new('UIScale',{Scale=1},avatarCanvas)
local function fitAvatar()
    local width=window.Size.X.Offset*.75
    local height=window.Size.Y.Offset-76
    if width>0 and height>0 then avatarScale.Scale=math.min(1,width/720,height/595) end
end
window:GetPropertyChangedSignal('Size'):Connect(fitAvatar)
fitAvatar()
local selectedColor=Color3.fromRGB(75,77,84)
local function avatarCard(parent,name,x,y,w,h,isButton)
    local f=new(isButton and 'TextButton' or 'Frame',{Name=name,Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),BackgroundColor3=C.side,BorderSizePixel=0},parent)
    if isButton then f.Text=''; f.AutoButtonColor=false end
    corner(f,8); stroke(f,C.line,.65,1)
    return f
end
-- Compact Check (#6): shared visual-only switch, preserving each original hit area.
local function compactCheck(button, width, height)
    local radius=math.floor(height/3+.5)
    button:FindFirstChildOfClass('UICorner').CornerRadius=UDim.new(0,radius)
    local outline=button:FindFirstChildOfClass('UIStroke')
    outline.Transparency=0
    local pad=height>=36 and 4 or 3
    local kh=height-2*pad
    local kw=height>=36 and 31 or 24
    local knob=new('Frame',{Name='Knob',Position=UDim2.fromOffset(pad,pad),Size=UDim2.fromOffset(kw,kh),BackgroundColor3=Color3.fromRGB(184,186,192),BorderSizePixel=0,Active=false,ZIndex=button.ZIndex+1},button)
    corner(knob,math.floor(kh*.32+.5))
    local mark=libraryIcon(knob,"check",UDim2.fromScale(.5,.5),math.min(kw,kh)*.82,"GreenCheck",Color3.fromRGB(40,123,59),Vector2.new(.5,.5))
    mark.Visible=false
    local previous, tweens=nil,{}
    local function show(on,animate)
        if previous==on and animate then return end
        previous=on
        for _,t in ipairs(tweens) do t:Cancel() end
        tweens={}
        mark.Visible=on
        local function apply(object,props)
            if animate then
                local t=TweenService:Create(object,TweenInfo.new(.18,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),props)
                table.insert(tweens,t); t:Play()
            else
                for k,v in pairs(props) do object[k]=v end
            end
        end
        apply(button,{BackgroundColor3=on and Color3.fromRGB(49,83,61) or Color3.fromRGB(65,67,73)})
        apply(outline,{Color=on and Color3.fromRGB(83,125,96) or Color3.fromRGB(100,102,109)})
        apply(knob,{Position=UDim2.fromOffset(on and (width-pad-kw) or pad,pad),BackgroundColor3=on and Color3.fromRGB(216,244,226) or Color3.fromRGB(184,186,192)})
    end
    show(false,false)
    return show
end

local function avatarText(parent,name,value,x,y,w,h,size,bold,center,mutedText)
    return new('TextLabel',{Name=name,Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),BackgroundTransparency=1,Text=value,TextColor3=mutedText and muted or C.text,Font=bold and Enum.Font.GothamMedium or Enum.Font.Gotham,TextSize=size,TextScaled=false,TextXAlignment=center and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center,TextTruncate=Enum.TextTruncate.AtEnd},parent)
end
-- Keep text and chevrons in separate fixed-width areas. Only shrink long row labels.
local avatarTextService=game:GetService('TextService')
local function avatarRowName(parent,name,value,x,w)
    local size=22
    while size>19 and avatarTextService:GetTextSize(value,size,Enum.Font.GothamMedium,Vector2.new(10000,52)).X>w do
        size=size-1
    end
    return avatarText(parent,name,value,x,0,w,52,size,true,false,false)
end
local avatarLibrary={user="user-round",users="users-round",hanger="hanger",cube="box",layers="layers",search="search",expand="maximize",shirt="shirt",pants="pants",face="smile",hat="hat",motion="run",tpose="person-standing",apose="walk",neutral="man"}
local function avatarIcon(parent,kind,x,y,size,strokeWidth)
    return libraryIcon(parent,avatarLibrary[kind],UDim2.fromOffset(x,y),size,kind.."Icon")
end
local function thin(parent,x,y,w)
    return new('Frame',{Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,1),BackgroundColor3=C.line,BackgroundTransparency=.55,BorderSizePixel=0},parent)
end
local function softPreview(button,callback)
    local scale=new('UIScale',{Scale=1},button)
    local tween,serial=nil,0
    button.Activated:Connect(function()
        if callback then callback() end
        serial=serial+1; local current=serial
        if tween then tween:Cancel() end
        tween=TweenService:Create(scale,TweenInfo.new(.10,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Scale=.94})
        tween.Completed:Once(function(state)
            if state~=Enum.PlaybackState.Completed or current~=serial or not button.Parent then return end
            tween=TweenService:Create(scale,TweenInfo.new(.13,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Scale=1}); tween:Play()
        end)
        tween:Play()
    end)
end
-- Home utilities: visual preview only, using the existing card and switch styles.
do
    local function buildHomeUtilities()
        local definitions={
            {id="AntiAFK",title="Анти-AFK",description="Защита от отключения за бездействие.",icon="clock"},
            {id="AutoSave",title="Автосохранение",description="Сохранение и восстановление настроек всех функций.",icon="save"},
            {id="ShiftLock",title="Shift Lock Switch",description="Плавающая кнопка фиксации камеры.",icon="lock"},
        }
        local firstY,step,height=566,88,76
        for i,definition in ipairs(definitions) do
            local card=panel(home,0,0,1,height,false)
            card.Name="Home"..definition.id.."Card"
            card.Position=UDim2.fromOffset(12,firstY+(i-1)*step)
            local glyph=libraryIcon(card,definition.icon,UDim2.fromOffset(14,18),40,definition.id.."Icon")
            local title=label(card,definition.title,64,7,1,28,23,true)
            title.Name="Title"
            title.Size=UDim2.new(1,-164,0,28)
            local description=label(card,definition.description,64,35,1,34,17,false)
            description.Name="Description"
            description.Size=UDim2.new(1,-164,0,34)
            description.TextWrapped=true
            description.TextTruncate=Enum.TextTruncate.None
            local toggle=avatarCard(card,"Toggle",0,0,80,36,true)
            toggle.AnchorPoint=Vector2.new(1,.5)
            toggle.Position=UDim2.new(1,-12,.5,0)
            local paint=compactCheck(toggle,80,36)
            local enabled=false
            toggle:SetAttribute("PreviewEnabled",enabled)
            softPreview(toggle,function()
                enabled=not enabled
                toggle:SetAttribute("PreviewEnabled",enabled)
                paint(enabled,true)
            end)
            -- Keep the standard landscape proportions; wrap labels in the narrow layout.
            local function fit()
                local narrow=window.Size.X.Offset<650
                if narrow then
                    glyph.Position=UDim2.fromOffset(8,18)
                    -- Scale from the existing icon holder's native 40px geometry.
                    local iconScale=glyph:FindFirstChildOfClass("UIScale")
                    if not iconScale then iconScale=new("UIScale",{Scale=.7},glyph) end
                    iconScale.Scale=.7
                    title.Position=UDim2.fromOffset(42,4)
                    title.Size=UDim2.new(1,-134,0,32)
                    title.TextSize=14
                    title.TextWrapped=true
                    title.TextTruncate=Enum.TextTruncate.None
                    description.Position=UDim2.fromOffset(42,36)
                    description.Size=UDim2.new(1,-134,0,36)
                    description.TextSize=11
                    toggle.Position=UDim2.new(1,-6,.5,0)
                else
                    glyph.Position=UDim2.fromOffset(14,18)
                    local iconScale=glyph:FindFirstChildOfClass("UIScale")
                    if iconScale then iconScale.Scale=1 end
                    title.Position=UDim2.fromOffset(64,7)
                    title.Size=UDim2.new(1,-164,0,28)
                    title.TextSize=23
                    title.TextWrapped=false
                    title.TextTruncate=Enum.TextTruncate.AtEnd
                    description.Position=UDim2.fromOffset(64,35)
                    description.Size=UDim2.new(1,-164,0,34)
                    description.TextSize=17
                    toggle.Position=UDim2.new(1,-12,.5,0)
                end
            end
            local resizeConnection=window:GetPropertyChangedSignal("Size"):Connect(fit)
            card.Destroying:Connect(function() resizeConnection:Disconnect() end)
            fit()
        end
        -- Preserve the original scroll container and include a bottom margin.
        home.CanvasSize=UDim2.fromOffset(0,firstY+(#definitions-1)*step+height+12)
    end
    buildHomeUtilities()
end

-- Existing Soft Press animation, without replacing the control callbacks.
softPreview(minimize)
softPreview(close)
local tabAvatar=avatarCard(avatarCanvas,'AvatarTab',12,12,344,46,true)
local tabOutfits=avatarCard(avatarCanvas,'OutfitsTab',364,12,344,46,true)
avatarIcon(tabAvatar,'user',120,10,26); avatarText(tabAvatar,'Caption','Аватар',154,0,120,46,21,true,false,false)
avatarIcon(tabOutfits,'hanger',112,10,26); avatarText(tabOutfits,'Caption','Наряды',146,0,130,46,21,true,false,false)
local avatarBody=new('Frame',{Name='AvatarColumns',Position=UDim2.fromOffset(12,70),Size=UDim2.fromOffset(696,513),BackgroundTransparency=1},avatarCanvas)
local outfitsBody=avatarCard(avatarCanvas,'OutfitsPlaceholder',12,70,696,501,false)
outfitsBody.Visible=false
avatarText(outfitsBody,'Caption','Наряды',16,8,660,42,22,true,false,false)
thin(outfitsBody,12,54,672)
local function selectAvatarTab(outfits)
    avatarBody.Visible=not outfits; outfitsBody.Visible=outfits
    tabAvatar.BackgroundColor3=outfits and C.slot or selectedColor
    tabOutfits.BackgroundColor3=outfits and selectedColor or C.slot
end
softPreview(tabAvatar,function() selectAvatarTab(false) end)
softPreview(tabOutfits,function() selectAvatarTab(true) end)
selectAvatarTab(false)
-- Equal-height columns: 180 + 304 + 196, with 8px gaps.
local playerPanel=avatarCard(avatarBody,'PlayerPanel',0,0,180,447,false)
local viewerPanel=avatarCard(avatarBody,'ViewerPanel',188,0,304,447,false)
local itemPanel=avatarCard(avatarBody,'ItemPanel',500,0,196,447,false)
local function panelHeading(p,kind,title,w,countValue)
    avatarIcon(p,kind,9,10,28)
    avatarText(p,'Heading',title,41,0,w-83,48,21,true,false,false)
    local badge=avatarCard(p,'Counter',w-43,11,33,26,false); badge.BackgroundColor3=C.slot
    avatarText(badge,'Value',tostring(countValue),0,0,33,26,19,true,true,false)
    thin(p,9,48,w-18)
end
panelHeading(playerPanel,'users','Игроки',180,4)
panelHeading(itemPanel,'layers','Предметы',196,12)
avatarIcon(viewerPanel,'cube',9,10,28)
avatarText(viewerPanel,'Heading','3D-просмотр',43,0,212,48,22,true,false,false)
local expand=avatarCard(viewerPanel,'ExpandPreview',263,7,32,32,true); avatarIcon(expand,'expand',5,5,22)
thin(viewerPanel,9,48,286)
local searchCard=avatarCard(playerPanel,'SearchBackground',8,56,164,34,false); searchCard.BackgroundColor3=C.content
avatarIcon(searchCard,'search',7,5,24)
local search=new('TextBox',{Name='SearchPlayers',Position=UDim2.fromOffset(35,0),Size=UDim2.fromOffset(123,34),BackgroundTransparency=1,Text='',PlaceholderText='Поиск игрока...',PlaceholderColor3=muted,TextColor3=C.text,Font=Enum.Font.Gotham,TextSize=16,TextXAlignment=Enum.TextXAlignment.Left,ClearTextOnFocus=false},searchCard)
local playerList=new('ScrollingFrame',{Name='SamplePlayers',Position=UDim2.fromOffset(8,98),Size=UDim2.fromOffset(164,341),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,CanvasSize=UDim2.fromOffset(0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y},playerPanel)
new('UIListLayout',{Padding=UDim.new(0,7),SortOrder=Enum.SortOrder.LayoutOrder},playerList)
local rows={}
local sampleNames={'Player_001','Player_002','Player_003','Player_004'}
for i,name in ipairs(sampleNames) do
    local row=avatarCard(playerList,'SamplePlayer'..i,0,0,160,52,true); row.LayoutOrder=i; row.BackgroundColor3=C.slot
    local face=avatarCard(row,'Portrait',4,6,40,40,false); face.BackgroundColor3=C.content; avatarIcon(face,'user',3,3,34,2.8)
    avatarRowName(row,'PlayerName',name,47,94)
    libraryIcon(row,'chevron-right',UDim2.fromOffset(136,14),24,'Arrow',C.text)
    rows[i]=row
    softPreview(row,function() for j,other in ipairs(rows) do other.BackgroundColor3=j==i and selectedColor or C.slot end end)
end
rows[1].BackgroundColor3=selectedColor
search:GetPropertyChangedSignal('Text'):Connect(function()
    local query=string.lower(search.Text)
    for i,row in ipairs(rows) do row.Visible=query=='' or string.find(string.lower(sampleNames[i]),query,1,true)~=nil end
end)
local items=new('ScrollingFrame',{Name='SampleCategories',Position=UDim2.fromOffset(8,56),Size=UDim2.fromOffset(180,383),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,CanvasSize=UDim2.fromOffset(0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y},itemPanel)
new('UIListLayout',{Padding=UDim.new(0,7),SortOrder=Enum.SortOrder.LayoutOrder},items)
for i,v in ipairs({{'hat','Аксессуары'},{'shirt','Одежда'},{'pants','Брюки'},{'face','Лица'},{'motion','Анимации'},{'cube','Другое'}}) do
    local row=avatarCard(items,'SampleCategory'..i,0,0,176,52,true); row.LayoutOrder=i; row.BackgroundColor3=C.slot
    avatarIcon(row,v[1],8,10,32); avatarRowName(row,'CategoryName',v[2],46,111)
    libraryIcon(row,'chevron-right',UDim2.fromOffset(152,14),24,'Arrow',C.text); softPreview(row)
end
-- Real native ViewportFrame with a simple locally constructed example mannequin.
local viewport=new('ViewportFrame',{Name='AvatarViewport',Position=UDim2.fromOffset(8,56),Size=UDim2.fromOffset(288,383),BackgroundColor3=C.content,BorderSizePixel=0,Ambient=Color3.fromRGB(165,165,165),LightColor=Color3.fromRGB(255,255,255),LightDirection=Vector3.new(-1,-1,-1)},viewerPanel)
corner(viewport,7)
local world=new('WorldModel',{Name='SampleWorld'},viewport)
local model=new('Model',{Name='DemoAvatar'},world)
local camera=new('Camera',{FieldOfView=35,CFrame=CFrame.lookAt(Vector3.new(0,3.25,12),Vector3.new(0,3,0))},viewport)
viewport.CurrentCamera=camera
local function block(name,size,pos,color,parent)
    return new('Part',{Name=name,Size=size,CFrame=CFrame.new(pos),Color=color,Material=Enum.Material.SmoothPlastic,Anchored=true,CanCollide=false,CastShadow=false,TopSurface=Enum.SurfaceType.Smooth,BottomSurface=Enum.SurfaceType.Smooth},parent or model)
end
local dark=Color3.fromRGB(30,30,33); local skin=Color3.fromRGB(218,218,221); local shoe=Color3.fromRGB(225,225,228)
block('Torso',Vector3.new(2,2,1),Vector3.new(0,3.1,0),dark)
block('Head',Vector3.new(1.55,1.45,1.25),Vector3.new(0,4.85,0),skin)
block('Cap',Vector3.new(1.65,.34,1.35),Vector3.new(0,5.53,0),dark)
block('CapBrim',Vector3.new(1.65,.12,.76),Vector3.new(0,5.42,.76),dark)
for _,sign in ipairs({-1,1}) do
    block('Eye',Vector3.new(.12,.22,.035),Vector3.new(sign*.28,4.98,.64),dark)
    block('Leg',Vector3.new(.94,1.75,.95),Vector3.new(sign*.51,1.22,0),Color3.fromRGB(42,42,45))
    block('Shoe',Vector3.new(.98,.3,1.15),Vector3.new(sign*.51,.21,.08),shoe)
end
for i=0,9 do
    local a=math.pi+i*math.pi/10; local b=a+math.pi/10
    local p=Vector3.new(.32*math.cos(a),4.76+.24*math.sin(a),.64)
    local q=Vector3.new(.32*math.cos(b),4.76+.24*math.sin(b),.64)
    local smile=block('Smile',Vector3.new((q-p).Magnitude+.02,.07,.035),(p+q)/2,dark)
    smile.CFrame=CFrame.new((p+q)/2)*CFrame.Angles(0,0,math.atan2(q.Y-p.Y,q.X-p.X))
end
local arms={}
for _,sign in ipairs({-1,1}) do
    local sleeve=block('Sleeve',Vector3.new(.85,1.2,.9),Vector3.new(0,0,0),dark)
    local hand=block('Hand',Vector3.new(.85,.72,.9),Vector3.new(0,0,0),skin)
    arms[#arms+1]={sign=sign,sleeve=sleeve,hand=hand}
end
local function pose(angle)
    for _,arm in ipairs(arms) do
        local joint=CFrame.new(arm.sign*1.45,4.05,0)*CFrame.Angles(0,0,arm.sign*angle)
        arm.sleeve.CFrame=joint*CFrame.new(0,-.60,0)
        arm.hand.CFrame=joint*CFrame.new(0,-1.56,0)
    end
end
pose(0)
local poseButtons={}
for i,v in ipairs({{'tpose','Т-поза',math.pi/2},{'apose','А-поза',math.pi/5},{'neutral','Нейтральная',0}}) do
    local x=({188,276,364})[i]
    local w=i==3 and 128 or 84
    local b=avatarCard(avatarBody,'Pose'..i,x,459,w,42,true)
    avatarIcon(b,v[1],5,11,20); avatarText(b,'Caption',v[2],28,0,w-30,42,14,true,false,false)
    poseButtons[i]=b
    softPreview(b,function() pose(v[3]); for j,other in ipairs(poseButtons) do other.BackgroundColor3=j==i and selectedColor or C.slot end end)
end
for i,b in ipairs(poseButtons) do b.BackgroundColor3=i==3 and selectedColor or C.slot end
local expanded=false
softPreview(expand,function()
    expanded=not expanded
    playerPanel.Visible=not expanded; itemPanel.Visible=not expanded
    viewerPanel.Position=UDim2.fromOffset(expanded and 0 or 188,0)
    viewerPanel.Size=UDim2.fromOffset(expanded and 696 or 304,447)
    viewport.Size=UDim2.fromOffset(expanded and 680 or 288,383)
    expand.Position=UDim2.fromOffset(expanded and 655 or 263,7)
end)

-- Player page: visual-only settings preview. Never changes the character or game.
local function buildPlayerPage()
    local page=new('Frame',{Name='PlayerPage',Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=false,ClipsDescendants=true},content)
    local canvas=new('Frame',{Name='PlayerCanvas',AnchorPoint=Vector2.new(.5,0),Position=UDim2.fromScale(.5,0),Size=UDim2.fromOffset(720,595),BackgroundTransparency=1},page)
    local scale=new('UIScale',{Scale=1},canvas)
    local function fit()
        local w,h=window.Size.X.Offset*.75,window.Size.Y.Offset-76
        if w>0 and h>0 then scale.Scale=math.min(1,w/720,h/595) end
    end
    window:GetPropertyChangedSignal('Size'):Connect(fit); fit()
    local function txt(p,name,value,x,y,w,h,size,bold,dim,wrap)
        local t=avatarText(p,name,value,x,y,w,h,size,bold,false,dim)
        if wrap then t.TextWrapped=true; t.TextTruncate=Enum.TextTruncate.None end
        return t
    end
    local playerLibrary={cube="box",motion="run",user="user-round",wing="feather",up="arrow-up",down="arrow-down",wall="wall",camera="camera",heart="heart",eye="eye",play="play",reset="refresh-cw"}
    local function icon(p,kind,x,y,size)
        return libraryIcon(p,playerLibrary[kind],UDim2.fromOffset(x,y),size,kind.."Icon")
    end
    icon(canvas,'motion',16,10,50)
    new('Frame',{Name='HeadingIconDivider',Position=UDim2.fromOffset(76,11),Size=UDim2.fromOffset(2,48),BackgroundColor3=Color3.fromRGB(143,145,152),BackgroundTransparency=.08,BorderSizePixel=0},canvas)
    txt(canvas,'Heading','Игрок',88,8,600,54,40,true,false,false).Font=Enum.Font.GothamBold
    local defs={
        {name='Флай',kind='wing',desc='Позволяет свободно летать по карте.',label='Скорость полёта',default=60,max=1000,manualMax=100000000},
        {name='NoClip',kind='cube',desc='Проходить сквозь стены и объекты.'},
        {name='Скорость',kind='motion',desc='Изменяет скорость передвижения.',label='Скорость движения',default=16,max=100,manualMax=1000},
        {name='Прыжок',kind='up',desc='Изменяет высоту прыжка.',label='Высота прыжка',default=50,max=150,manualMax=1000},
        {name='Гравитация',kind='down',desc='Изменение гравитации.',label='Гравитация',default=196.2,max=500,manualMax=100000},
        {name='Ходьба по стенам',kind='wall',desc='Передвижение по стенам.'},
        {name='Свободная камера',kind='camera',desc='Свободный обзор карты.',group='Утилиты',label='Скорость камеры',default=50,max=2000,sliderOnly=true},
    }
    local states, cards, outlines={}, {}, {}
    local list=new('ScrollingFrame',{Name='PlayerOptionsScroll',Position=UDim2.fromOffset(12,72),Size=UDim2.fromOffset(304,476),BackgroundTransparency=1,BorderSizePixel=0,CanvasSize=UDim2.fromOffset(0,0),ScrollingDirection=Enum.ScrollingDirection.Y,ScrollBarThickness=4,ScrollBarImageColor3=C.line,ClipsDescendants=true},canvas)
    local y=0
    for i,d in ipairs(defs) do
        if d.group then
            txt(list,'UtilityHeading',d.group,8,y,280,34,23,true,false,false)
            y=y+42
        end
        states[i]={enabled=false,value=d.default or 0,manual=tostring(d.default or 0)}
        -- Match ESP v36 card geometry, typography and icon alignment.
        local b=avatarCard(list,'PlayerOption'..i,0,y,296,98,true)
        y=y+108
        b.BackgroundColor3=C.slot; cards[i]=b; outlines[i]=b:FindFirstChildOfClass('UIStroke')
        icon(b,d.kind,12,28,40)
        new('Frame',{Name='CardIconDivider',Position=UDim2.fromOffset(59,19),Size=UDim2.fromOffset(1,60),BackgroundColor3=C.line,BackgroundTransparency=.28,BorderSizePixel=0,Active=false},b)
        local caption=txt(b,'Title',d.name,70,9,214,32,22,true,false,false)
        caption.Font=Enum.Font.GothamBold
        local size=22
        while size>18 and avatarTextService:GetTextSize(d.name,size,caption.Font,Vector2.new(10000,32)).X>214 do size=size-1 end
        caption.TextSize=size
        local desc=txt(b,'Description',d.desc,70,44,214,44,17,false,true,true)
        desc.TextColor3=Color3.fromRGB(193,195,202)
        desc.TextYAlignment=Enum.TextYAlignment.Top
    end
    list.CanvasSize=UDim2.fromOffset(0,y-10)
    local detail=avatarCard(canvas,'PlayerSettings',320,72,388,476,false)
    detail.BackgroundColor3=C.slot
    local symbol
    local title=txt(detail,'Title','',66,14,214,40,29,true,false,false)
    local description=txt(detail,'Description','',16,66,356,56,20,false,true,true)
    thin(detail,16,132,356)
    local toggle=avatarCard(detail,'EnableToggle',292,20,80,36,true)
    local showPlayerToggle=compactCheck(toggle,80,36)
    local controls=new('Frame',{Name='NumericSettings',Position=UDim2.fromOffset(16,144),Size=UDim2.fromOffset(356,236),BackgroundTransparency=1},detail)
    local fieldTitle=txt(controls,'SliderHeading','',0,0,356,34,23,true,false,false)
    local touchTrack=new('Frame',{Name='SliderTouchArea',Position=UDim2.fromOffset(0,39),Size=UDim2.fromOffset(268,48),BackgroundTransparency=1,Active=true},controls)
    local rail=new('Frame',{Position=UDim2.fromOffset(11,19),Size=UDim2.fromOffset(246,10),BackgroundColor3=Color3.fromRGB(82,84,90),BorderSizePixel=0},touchTrack); corner(rail,5)
    local fill=new('Frame',{Size=UDim2.fromScale(0,1),BackgroundColor3=Color3.fromRGB(177,179,185),BorderSizePixel=0},rail); corner(fill,5)
    local thumb=new('Frame',{Name='SliderThumb',AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(0,.5),Size=UDim2.fromOffset(25,25),BackgroundColor3=C.text,BorderSizePixel=0},rail); corner(thumb,13)
    local valueCard=avatarCard(controls,'SliderValue',280,41,76,44,false); valueCard.BackgroundColor3=C.side
    local valueLabel=avatarText(valueCard,'Value','60',0,0,76,44,22,true,true,false)
    local manualHeading=txt(controls,'ManualHeading','Ввести вручную',0,98,356,32,21,false,true,false)
    local rangeMin=txt(controls,'SliderMinimum','0',11,89,50,22,16,false,true,false)
    local rangeMax=txt(controls,'SliderMaximum','2000',187,89,70,22,16,false,true,false)
    rangeMax.TextXAlignment=Enum.TextXAlignment.Right
    rangeMin.Visible=false; rangeMax.Visible=false
    local inputBg=avatarCard(controls,'ManualBackground',0,136,356,48,false); inputBg.BackgroundColor3=C.side
    local input=new('TextBox',{Name='ManualValue',Position=UDim2.fromOffset(12,0),Size=UDim2.new(1,-24,1,0),BackgroundTransparency=1,Text='60',TextColor3=C.text,PlaceholderText='Введите число',PlaceholderColor3=muted,Font=Enum.Font.GothamMedium,TextSize=23,TextScaled=false,TextXAlignment=Enum.TextXAlignment.Left,ClearTextOnFocus=false},inputBg)
    local note=txt(controls,'PreviewNotice','Настройки пока демонстрационные.',0,193,356,40,17,false,true,true)
    local noSettings=txt(detail,'NoNumericSettings','Дополнительных настроек нет.',16,150,356,72,21,false,true,true)
    local reset=avatarCard(detail,'ResetButton',187,406,185,54,true); reset.BackgroundColor3=selectedColor
    icon(reset,'reset',12,14,26); txt(reset,'Caption','Сброс',48,0,130,54,21,true,false,false)
    local current=1
    local dragInput=nil
    local function refreshValue()
        local d,s=defs[current],states[current]
        if not d.max then return end
        local fraction=math.clamp(s.value/d.max,0,1)
        fill.Size=UDim2.fromScale(fraction,1); thumb.Position=UDim2.fromScale(fraction,.5)
        valueLabel.Text=tostring(s.value)
        local size=22
        while size>12 and avatarTextService:GetTextSize(valueLabel.Text,size,Enum.Font.GothamMedium,Vector2.new(1000,44)).X>70 do size=size-1 end
        valueLabel.TextSize=size
    end
    local function refreshToggle(animate)
        local on=states[current].enabled
        showPlayerToggle(on,animate)
    end
    local function choose(i)
        if input:IsFocused() then input:ReleaseFocus() end
        dragInput=nil; current=i
        local d,s=defs[i],states[i]
        for j,b in ipairs(cards) do
            b.BackgroundColor3=j==i and selectedColor or C.slot
            outlines[j].Transparency=j==i and .16 or .65
        end
        if symbol then symbol:Destroy() end
        symbol=icon(detail,d.kind,16,14,40)
        title.Text=d.name; description.Text=d.desc
        title.TextSize=29
        while title.TextSize>18 and avatarTextService:GetTextSize(d.name,title.TextSize,Enum.Font.GothamMedium,Vector2.new(10000,40)).X>214 do title.TextSize=title.TextSize-1 end
        toggle.Visible=not d.unavailable; reset.Visible=not d.unavailable and d.name~='NoClip'
        controls.Visible=d.max~=nil; noSettings.Visible=d.max==nil
        local sliderOnly=d.sliderOnly==true
        manualHeading.Visible=not sliderOnly; inputBg.Visible=not sliderOnly
        rangeMin.Visible=sliderOnly; rangeMax.Visible=sliderOnly
        note.Position=UDim2.fromOffset(0,sliderOnly and 121 or 193)
        noSettings.Text=d.unavailable and 'Функция пока не подключена.' or 'Дополнительных настроек нет.'
        fieldTitle.Text=d.label or ''; input.Text=s.manual
        refreshValue(); refreshToggle(false)
    end
    for i,b in ipairs(cards) do softPreview(b,function()
        choose(i)
    end) end
    local function flip()
        if defs[current].unavailable then return end
        states[current].enabled=not states[current].enabled; refreshToggle(true)
    end
    softPreview(toggle,flip)
    softPreview(reset,function()
        local d,s=defs[current],states[current]
        s.enabled=false; s.value=d.default or 0; s.manual=tostring(s.value); input.Text=s.manual
        refreshValue(); refreshToggle(true)
        showToast('Настройки сброшены')
    end)
    input.FocusLost:Connect(function()
        local d,s=defs[current],states[current]
        if not d.max or d.sliderOnly or not d.manualMax then return end
        local n=tonumber(input.Text)
        if n and n==n and n>=0 and n<=d.manualMax then
            s.value=math.floor(n+.5); s.manual=tostring(s.value)
            showToast('Значение принято')
        end
        input.Text=s.manual; refreshValue()
    end)
    local function setSlider(x)
        local d=defs[current]; if not d.max or rail.AbsoluteSize.X<=0 then return end
        local fraction=math.clamp((x-rail.AbsolutePosition.X)/rail.AbsoluteSize.X,0,1)
        states[current].value=math.floor(fraction*d.max+.5)
        refreshValue() -- Manual entry stays independent of slider movements.
    end
    touchTrack.InputBegan:Connect(function(event)
        if event.UserInputType==Enum.UserInputType.Touch or event.UserInputType==Enum.UserInputType.MouseButton1 then
            dragInput=event; setSlider(event.Position.X)
        end
    end)
    local changed=UserInputService.InputChanged:Connect(function(event)
        if not page.Visible or not body.Visible then dragInput=nil; return end
        if not dragInput then return end
        if (dragInput.UserInputType==Enum.UserInputType.Touch and event==dragInput) or (dragInput.UserInputType==Enum.UserInputType.MouseButton1 and event.UserInputType==Enum.UserInputType.MouseMovement) then setSlider(event.Position.X) end
    end)
    local ended=UserInputService.InputEnded:Connect(function(event)
        if dragInput and (event==dragInput or (dragInput.UserInputType==Enum.UserInputType.MouseButton1 and event.UserInputType==Enum.UserInputType.MouseButton1)) then dragInput=nil end
    end)
    page:GetPropertyChangedSignal('Visible'):Connect(function() if not page.Visible then dragInput=nil end end)
    gui.Destroying:Connect(function() changed:Disconnect(); ended:Disconnect() end)
    choose(1)
    return page
end
local playerPage=buildPlayerPage()

-- ESP page: local UI state only; no highlighting, scanning or gameplay changes.
local function buildESPPage()
    local page=new('Frame',{Name='ESPPage',Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=false,ClipsDescendants=true},content)
    local canvas=new('Frame',{Name='ESPCanvas',AnchorPoint=Vector2.new(.5,0),Position=UDim2.fromScale(.5,0),Size=UDim2.fromOffset(720,595),BackgroundTransparency=1},page)
    local scale=new('UIScale',{Scale=1},canvas)
    local function fit()
        local w,h=window.Size.X.Offset*.75,window.Size.Y.Offset-76
        if w>0 and h>0 then scale.Scale=math.min(1,w/720,h/595) end
    end
    window:GetPropertyChangedSignal('Size'):Connect(fit); fit()
    local function txt(p,name,value,x,y,w,h,size,bold,dim,center)
        return avatarText(p,name,value,x,y,w,h,size,bold,center or false,dim or false)
    end
    local espLibrary={user="user-round",cube="box",eye="eye",bot="bot",sun="sun",chevron="chevron-down",check="check"}
    local function icon(p,kind,x,y,size)
        return libraryIcon(p,espLibrary[kind],UDim2.fromOffset(x,y),size,kind.."Icon")
    end
    icon(canvas,'eye',16,16,50)
    new('Frame',{Name='HeadingIconDivider',Position=UDim2.fromOffset(76,17),Size=UDim2.fromOffset(2,48),BackgroundColor3=Color3.fromRGB(143,145,152),BackgroundTransparency=.08,BorderSizePixel=0},canvas)
    txt(canvas,'Heading','ESP',88,8,600,44,40,true,false).Font=Enum.Font.GothamBold
    txt(canvas,'Subtitle','Визуализация игроков и объектов',88,52,600,26,19,false,true)
    local defs={
        {'Игроки ESP','Обнаружение игроков','user','Обнаружение игроков'},
        {'ESP NPC','NPC и монстры','bot','Обнаружение NPC'},
        {'Предметы ESP','Поиск предметов','cube','Поиск предметов'},
        {'Убрать туман','Осветить карту','sun','Освещение карты'},
    }
    local colors={Color3.fromRGB(89,228,133),Color3.fromRGB(245,87,97),Color3.fromRGB(105,184,255),Color3.fromRGB(245,245,245),Color3.fromRGB(255,204,110),Color3.fromRGB(185,150,255)}
    local hexColors={'#59E485','#F55761','#69B8FF','#F5F5F5','#FFCC6E','#B996FF'}
    local modes={'Неон','Баланс','Радуга RGB'}
    local states,cards,outlines={},{},{}
    local current=1
    for i,d in ipairs(defs) do
        states[i]={enabled=false,mode=i==1 and 2 or 1,color=i==2 and 2 or 1,checks={true,true,true}}
        -- Like Player, the entire left card selects a function; it never enables it.
        local b=avatarCard(canvas,'ESPOption'..i,12,94+(i-1)*108,296,98,true)
        b.BackgroundColor3=C.slot; cards[i]=b; outlines[i]=b:FindFirstChildOfClass('UIStroke')
        icon(b,d[3],12,28,40)
        new('Frame',{Name='CardIconDivider',Position=UDim2.fromOffset(59,19),Size=UDim2.fromOffset(1,60),BackgroundColor3=C.line,BackgroundTransparency=.28,BorderSizePixel=0,Active=false},b)
        local title=txt(b,'Title',d[1],70,9,214,32,22,true,false)
        title.Font=Enum.Font.GothamBold
        local size=22
        while size>18 and avatarTextService:GetTextSize(d[1],size,title.Font,Vector2.new(10000,32)).X>214 do size=size-1 end
        title.TextSize=size
        local desc=txt(b,'Description',d[2],70,44,214,44,17,false,true)
        desc.TextWrapped=true; desc.TextTruncate=Enum.TextTruncate.None
        desc.TextColor3=Color3.fromRGB(193,195,202)
        desc.TextYAlignment=Enum.TextYAlignment.Top
        b:SetAttribute('OptionIndex',i)
    end
    local detail=avatarCard(canvas,'ESPSettings',320,94,388,470,false); detail.BackgroundColor3=C.slot
    local symbol,symbolIndex
    local title=txt(detail,'Title','',62,14,220,40,25,true,false)
    local description=txt(detail,'Description','',14,62,360,43,19,false,true)
    description.TextWrapped=true; description.TextTruncate=Enum.TextTruncate.None
    local toggle=avatarCard(detail,'EnableToggle',294,20,80,36,true)
    local showESPToggle=compactCheck(toggle,80,36)
    thin(detail,14,112,360)
    -- Settings occupy their own area below the common header.
    local settings=new('Frame',{Name='TargetSettings',Position=UDim2.fromOffset(0,122),Size=UDim2.new(1,0,1,-122),BackgroundTransparency=1},detail)
    txt(settings,'DataTitle','Отображение данных',14,0,360,32,21,true,false)
    local checks={}
    local function refreshChecks()
        for i,c in ipairs(checks) do local on=states[current].checks[i]; c.square.BackgroundColor3=on and selectedColor or C.content; c.mark.Visible=on end
        checks[1].label.Text=current==2 and 'Имя NPC' or 'Никнейм'
    end
    for i,name in ipairs({'Никнейм','Расстояние','Здоровье'}) do
        local y=36+(i-1)*43
        local b=new('TextButton',{Name='Check'..i,Position=UDim2.fromOffset(14,y),Size=UDim2.fromOffset(360,40),BackgroundTransparency=1,Text='',AutoButtonColor=false},settings)
        local square=avatarCard(b,'Square',0,6,28,28,false)
        local mark=icon(square,'check',4,4,20)
        local label=txt(b,'Caption',name,42,0,310,40,21,false,false)
        checks[i]={square=square,mark=mark,label=label}
        b.Activated:Connect(function() if current>2 then return end; states[current].checks[i]=not states[current].checks[i]; refreshChecks() end)
    end
    thin(settings,14,169,360)
    txt(settings,'ModeTitle','Стиль подсветки',14,181,196,42,20,false,false)
    local mode=avatarCard(settings,'ModeSelect',207,181,167,42,true); mode.BackgroundColor3=C.side
    local modeLabel=txt(mode,'Caption','',9,0,128,42,19,false,false); icon(mode,'chevron',139,11,20)
    txt(settings,'ColorTitle','Цвет ESP',14,236,196,42,20,false,false)
    local color=avatarCard(settings,'ColorSelect',207,236,167,42,true); color.BackgroundColor3=C.side
    local swatch=new('Frame',{Position=UDim2.fromOffset(10,8),Size=UDim2.fromOffset(26,26),BackgroundColor3=colors[1],BorderSizePixel=0},color); corner(swatch,5)
    local colorLabel=txt(color,'Caption','',45,0,90,42,17,false,false); icon(color,'chevron',139,11,20)
    local summary=txt(detail,'Summary','Дополнительных настроек нет.',14,138,360,72,21,false,true)
    summary.TextWrapped=true; summary.TextTruncate=Enum.TextTruncate.None; summary.TextYAlignment=Enum.TextYAlignment.Top
    local popup=nil
    local function hidePopup() if popup then popup:Destroy(); popup=nil end end
    local function refresh(animateToggle)
        local s,d=states[current],defs[current]
        if symbolIndex~=current then
            if symbol then symbol:Destroy() end
            symbol=icon(detail,d[3],14,14,40)
            symbolIndex=current
        end
        title.Text=d[1]
        title.TextSize=25
        while title.TextSize>18 and avatarTextService:GetTextSize(title.Text,title.TextSize,Enum.Font.GothamMedium,Vector2.new(10000,40)).X>220 do title.TextSize=title.TextSize-1 end
        description.Text=current==3 and 'Поиск предметов и мест их применения.'
            or current==4 and 'Убирает туман и осветляет карту.' or d[4]
        for i,b in ipairs(cards) do
            b.BackgroundColor3=i==current and selectedColor or C.slot
            outlines[i].Transparency=i==current and .16 or .65
        end
        showESPToggle(s.enabled,animateToggle==true)
        settings.Visible=current<=2; summary.Visible=current>2
        if current<=2 then
            modeLabel.Text=modes[s.mode]; swatch.BackgroundColor3=colors[s.color]; colorLabel.Text=hexColors[s.color]; refreshChecks()
        end
    end
    local function openPicker(kind)
        if current>2 then return end
        local same=popup and popup.Name==kind
        hidePopup(); if same then return end
        if kind=='ModePicker' then
            popup=avatarCard(settings,kind,207,68,167,111,false); popup.BackgroundColor3=C.header; popup.ZIndex=10
            for i,v in ipairs(modes) do
                local b=avatarCard(popup,'Choice'..i,5,4+(i-1)*35,157,32,true); b.BackgroundColor3=C.slot
                txt(b,'Caption',v,8,0,141,32,19,false,false)
                b.Activated:Connect(function() states[current].mode=i; hidePopup(); refresh() end)
            end
        else
            popup=avatarCard(settings,kind,207,134,167,100,false); popup.BackgroundColor3=C.header; popup.ZIndex=10
            for i,v in ipairs(colors) do
                local b=avatarCard(popup,'Color'..i,8+((i-1)%3)*51,8+math.floor((i-1)/3)*45,43,39,true); b.BackgroundColor3=v
                b.Activated:Connect(function() states[current].color=i; hidePopup(); refresh() end)
            end
        end
    end
    for i,b in ipairs(cards) do
        softPreview(b,function() hidePopup(); current=i; refresh(false) end)
    end
    softPreview(toggle,function()
        hidePopup()
        states[current].enabled=not states[current].enabled
        showESPToggle(states[current].enabled,true)
    end)
    softPreview(mode,function() openPicker('ModePicker') end)
    softPreview(color,function() openPicker('ColorPicker') end)
    page:GetPropertyChangedSignal('Visible'):Connect(function() if not page.Visible then hidePopup() end end)
    refresh()
    return page
end
local espPage=buildESPPage()

-- Defense page: same geometry and reusable controls as ESP; visual state only.
local defensePage=(function()
    local page=new('Frame',{Name='DefensePage',Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=false,ClipsDescendants=true},content)
    local canvas=new('Frame',{Name='DefenseCanvas',AnchorPoint=Vector2.new(.5,0),Position=UDim2.fromScale(.5,0),Size=UDim2.fromOffset(720,595),BackgroundTransparency=1},page)
    local scale=new('UIScale',{Scale=1},canvas)
    local function fit()
        local w,h=window.Size.X.Offset*.75,window.Size.Y.Offset-76
        if w>0 and h>0 then scale.Scale=math.min(1,w/720,h/595) end
    end
    local resizeConnection=window:GetPropertyChangedSignal('Size'):Connect(fit)
    page.Destroying:Connect(function() resizeConnection:Disconnect() end)
    fit()
    local function txt(p,name,value,x,y,w,h,size,bold,dim,wrap)
        local t=avatarText(p,name,value,x,y,w,h,size,bold,false,dim)
        if wrap then t.TextWrapped=true; t.TextTruncate=Enum.TextTruncate.None end
        return t
    end
    local function icon(p,key,x,y,size,name)
        return libraryIcon(p,key,UDim2.fromOffset(x,y),size,name or key..'Icon')
    end
    icon(canvas,'shield',16,16,50)
    new('Frame',{Name='HeadingIconDivider',Position=UDim2.fromOffset(76,17),Size=UDim2.fromOffset(2,48),BackgroundColor3=Color3.fromRGB(143,145,152),BackgroundTransparency=.08,BorderSizePixel=0},canvas)
    txt(canvas,'Heading','Защита',88,8,600,44,40,true,false).Font=Enum.Font.GothamBold
    txt(canvas,'Subtitle','Безопасность персонажа',88,52,600,26,19,false,true)
    local defs={
        {name='Защита от отбрасывания',heading='Защита от\nотбрасывания',desc='Защита от резкого отбрасывания.',key='shield',settings={'Уведомления','Восстановление управления'}},
        {name='Защита от падения под карту',heading='Защита от падения\nпод карту',desc='Защита от падения за пределы карты.',key='arrow-down',settings={'Уведомления','Возврат в безопасное место'}},
        {name='Бессмертие',heading='Бессмертие',desc='Функция пока не подключена.',key='heart',unavailable=true},
        {name='Защита от посадки',heading='Защита от посадки',desc='Защита от нежелательной посадки.',key='person-standing',settings={'Обычные сиденья','Сиденья транспорта','Уведомления'},defaults={true,true,false}},
    }
    local states,cards,outlines={},{},{}
    for i,d in ipairs(defs) do
        states[i]={enabled=false,checks=d.defaults or {true,true}}
        local b=avatarCard(canvas,'DefenseOption'..i,12,94+(i-1)*108,296,98,true)
        b.BackgroundColor3=C.slot
        cards[i]=b; outlines[i]=b:FindFirstChildOfClass('UIStroke')
        icon(b,d.key,12,28,40)
        new('Frame',{Name='CardIconDivider',Position=UDim2.fromOffset(59,19),Size=UDim2.fromOffset(1,60),BackgroundColor3=C.line,BackgroundTransparency=.28,BorderSizePixel=0,Active=false},b)
        local multiline=string.find(d.heading,"\n",1,true)~=nil
        local title=txt(b,'Title',d.heading,70,multiline and 5 or 9,214,multiline and 45 or 32,multiline and 20 or 22,true,false,true)
        title.Font=Enum.Font.GothamBold
        while title.TextSize>18 and avatarTextService:GetTextSize(d.heading,title.TextSize,title.Font,Vector2.new(10000,45)).X>214 do title.TextSize=title.TextSize-1 end
        local desc=txt(b,'Description',d.desc,70,multiline and 52 or 44,214,multiline and 40 or 44,17,false,true,true)
        desc.TextColor3=Color3.fromRGB(193,195,202)
        desc.TextYAlignment=Enum.TextYAlignment.Top
        b:SetAttribute('OptionIndex',i)
    end
    local detail=avatarCard(canvas,'DefenseSettings',320,94,388,470,false)
    detail.BackgroundColor3=C.slot
    local symbol,symbolIndex
    local title=txt(detail,'Title','',62,8,220,52,23,true,false,true)
    local description=txt(detail,'Description','',14,62,360,43,19,false,true,true)
    local toggle=avatarCard(detail,'EnableToggle',294,20,80,36,true)
    local showToggle=compactCheck(toggle,80,36)
    thin(detail,14,112,360)
    local settings=new('Frame',{Name='ProtectionSettings',Position=UDim2.fromOffset(0,122),Size=UDim2.new(1,0,1,-122),BackgroundTransparency=1},detail)
    txt(settings,'SettingsTitle','Настройки защиты',14,0,360,32,21,true,false)
    local notice=txt(detail,'PreviewNotice','Функции пока не подключены.',14,260,360,58,19,false,true,true)
    local summary=txt(detail,'Summary','Функция пока не подключена.',14,138,360,72,21,false,true,true)
    local current=1
    local checks={}
    local settingsDivider=thin(settings,14,126,360)
    local function refreshChecks()
        local d=defs[current]
        if not d.settings then return end
        for i,c in ipairs(checks) do
            local label=d.settings[i]
            c.button.Visible=label~=nil
            if label then
                local on=states[current].checks[i]
                c.square.BackgroundColor3=on and selectedColor or C.content
                c.mark.Visible=on
                c.label.Text=label
            end
        end
        settingsDivider.Position=UDim2.fromOffset(14,#d.settings==3 and 169 or 126)
        notice.Position=UDim2.fromOffset(14,#d.settings==3 and 303 or 260)
    end
    for i=1,3 do
        local b=new('TextButton',{Name='Check'..i,Position=UDim2.fromOffset(14,36+(i-1)*43),Size=UDim2.fromOffset(360,40),BackgroundTransparency=1,Text='',AutoButtonColor=false},settings)
        local square=avatarCard(b,'Square',0,6,28,28,false)
        local mark=icon(square,'check',4,4,20)
        local label=txt(b,'Caption','',42,0,310,40,20,false,false,true)
        checks[i]={button=b,square=square,mark=mark,label=label}
        b.Activated:Connect(function()
            if defs[current].unavailable or not defs[current].settings or not defs[current].settings[i] then return end
            states[current].checks[i]=not states[current].checks[i]
            refreshChecks()
        end)
    end
    local function refresh(animate)
        local d,state=defs[current],states[current]
        if symbolIndex~=current then
            if symbol then symbol:Destroy() end
            symbol=icon(detail,d.key,14,14,40)
            symbolIndex=current
        end
        title.Text=d.heading
        description.Text=d.desc
        for i,b in ipairs(cards) do
            b.BackgroundColor3=i==current and selectedColor or C.slot
            outlines[i].Transparency=i==current and .16 or .65
        end
        toggle.Visible=not d.unavailable
        settings.Visible=not d.unavailable
        notice.Visible=not d.unavailable
        summary.Visible=d.unavailable==true
        showToggle(state.enabled,animate==true)
        refreshChecks()
    end
    for i,b in ipairs(cards) do
        softPreview(b,function() current=i; refresh(false) end)
    end
    softPreview(toggle,function()
        if defs[current].unavailable then return end
        states[current].enabled=not states[current].enabled
        refresh(true)
    end)
    refresh(false)
    return page
end)()


local buttons = {}
local navigationLabels = {}
local function selectTab(index)
    home.Visible = index == 1
    avatarPage.Visible = index == 2
    playerPage.Visible = index == 3
    espPage.Visible = index == 4
    defensePage.Visible = index == 6
    overlay.Visible = false
    for i, button in ipairs(buttons) do
        button.BackgroundColor3 = i == index and Color3.fromRGB(75,77,84) or C.slot
    end
end
layout.VerticalAlignment = Enum.VerticalAlignment.Top
layout.Padding = UDim.new(0,9)
for i, name in ipairs(names) do
    local wrapper = new("Frame", {
        Name="NavigationLayout"..i, LayoutOrder=i,
        Size=UDim2.new(1,-20,0,64), BackgroundTransparency=1, BorderSizePixel=0,
    },slots)
    local slot = new("TextButton", {
        Name="Navigation"..i, Text="",
        AnchorPoint=Vector2.new(.5,.5), Position=UDim2.fromScale(.5,.5),
        Size=UDim2.fromScale(1,1), BackgroundColor3=C.slot,
        BorderSizePixel=0, AutoButtonColor=false,
    },wrapper)
    corner(slot,8)
    stroke(slot,C.line,.72,1)
    local iconLabel = drawIcon(slot,i)
    local nameLabel = new("TextLabel", {Position=UDim2.fromOffset(56,0), Size=UDim2.new(1,-62,1,0), BackgroundTransparency=1, Text=name, TextColor3=C.text, Font=Enum.Font.GothamMedium, TextSize=25, TextScaled=false, TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Center},slot)
    navigationLabels[i]={iconLabel,nameLabel}
    buttons[i]=slot
    local pressScale = new("UIScale", {Scale=1},slot)
    local activeTween
    local generation=0
    slot.Activated:Connect(function()
        selectTab(i)
        generation=generation+1
        local current=generation
        if activeTween then activeTween:Cancel() end
        local down=TweenService:Create(pressScale,TweenInfo.new(.10,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Scale=.94})
        activeTween=down
        down.Completed:Once(function(state)
            if state~=Enum.PlaybackState.Completed or current~=generation or not slot.Parent then return end
            activeTween=TweenService:Create(pressScale,TweenInfo.new(.13,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Scale=1})
            activeTween:Play()
        end)
        down:Play()
    end)
end
selectTab(1)

-- Sidebar footer: flat, noninteractive branding and local UI status.
-- Six navigation wrappers end at y=441 (12 + 6*64 + 5*9).
do
    local footer=new("Frame",{
        Name="NavigationFooter", Position=UDim2.fromOffset(20,461),
        Size=UDim2.new(1,-40,0,120), BackgroundTransparency=1,
        BorderSizePixel=0, Active=false,
    },sidebar)
    new("Frame",{
        Name="FooterDivider", Position=UDim2.fromOffset(0,0),
        Size=UDim2.new(1,0,0,1), BackgroundColor3=C.line,
        BackgroundTransparency=.12, BorderSizePixel=0,
    },footer)
    libraryIcon(footer,"info",UDim2.fromOffset(8,25),30,"FooterInfoIcon",muted)
    local title=label(footer,"HORIZON UI 2.0",52,17,1,24,16,true)
    title.Name="FooterTitle"
    title.Size=UDim2.new(1,-52,0,24)
    title.Font=Enum.Font.GothamMedium
    local version=label(footer,"Версия: 2.0",52,42,1,22,14,false)
    version.Name="FooterVersion"
    version.Size=UDim2.new(1,-52,0,22)
    libraryIcon(footer,"refresh-cw",UDim2.fromOffset(8,76),30,"FooterStatusIcon",muted)
    local status=label(footer,"Статус: <font color=\"#79B96B\">Активен</font>",52,75,1,32,15,false)
    status.Name="FooterStatus"
    status.Size=UDim2.new(1,-52,0,32)
    status.TextColor3=C.text
    status.RichText=true
    -- The status refers only to the currently mounted UI, not server safety.
    -- Hide the decorative footer in the narrow portrait layout rather than clip text.
    local function fitFooter()
        local size=window.Size
        footer.Visible=size.X.Offset>=800 and size.Y.Offset>=657
    end
    local footerResize=window:GetPropertyChangedSignal("Size"):Connect(fitFooter)
    footer.Destroying:Connect(function() footerResize:Disconnect() end)
    fitFooter()
end

-- Drag from the header on mouse or touch, without hijacking close/minimize taps.
local dragging=false
local dragStart
local startPosition
local dragInput
local endedConnection
header.InputBegan:Connect(function(input)
    if input.UserInputType~=Enum.UserInputType.MouseButton1 and input.UserInputType~=Enum.UserInputType.Touch then return end
    local point=input.Position
    local minButton=minimize.AbsolutePosition
    local closeButton=close.AbsolutePosition
    local function inside(pos, size)
        return point.X>=pos.X and point.X<=pos.X+size.X and point.Y>=pos.Y and point.Y<=pos.Y+size.Y
    end
    if inside(minButton,minimize.AbsoluteSize) or inside(closeButton,close.AbsoluteSize) then return end
    dragging=true
    dragStart=point
    startPosition=window.Position
    dragInput=input
end)
UserInputService.InputChanged:Connect(function(input)
    if not dragging or not dragStart then return end
    if dragInput.UserInputType==Enum.UserInputType.Touch then
        if input~=dragInput then return end
    elseif input.UserInputType~=Enum.UserInputType.MouseMovement then
        return
    end
    local delta=input.Position-dragStart
    window.Position=UDim2.new(startPosition.X.Scale,startPosition.X.Offset+delta.X,startPosition.Y.Scale,startPosition.Y.Offset+delta.Y)
end)
UserInputService.InputEnded:Connect(function(input)
    if input==dragInput or (dragInput and dragInput.UserInputType==Enum.UserInputType.MouseButton1 and input.UserInputType==Enum.UserInputType.MouseButton1) then
        dragging=false
        dragInput=nil
    end
end)

-- Compact floating launcher. The main window keeps its full size and
-- position; visibility is switched directly, without a transition.
do
    local launcher=new("TextButton",{
        Name="HorizonFloatingButton",
        AnchorPoint=Vector2.new(0,.5),
        Position=UDim2.new(0,20,.5,0),
        Size=UDim2.fromOffset(58,58),
        BackgroundColor3=Color3.fromRGB(35,37,42),BorderSizePixel=0,
        Text="H",TextColor3=C.text,Font=Enum.Font.GothamBold,TextSize=27,
        TextXAlignment=Enum.TextXAlignment.Center,
        TextYAlignment=Enum.TextYAlignment.Center,
        AutoButtonColor=false,Active=true,ZIndex=10,
    },gui)
    corner(launcher,14)
    stroke(launcher,Color3.fromRGB(121,129,143),.10,1.3).ApplyStrokeMode=Enum.ApplyStrokeMode.Border

    local function setWindowVisible(visible)
        collapsed=not visible
        dragging=false
        dragInput=nil
        dragStart=nil
        overlay.Visible=false
        if not visible then
            local toast=window:FindFirstChild("HorizonProgressToast")
            if toast then toast:Destroy() end
        end
        body.Visible=visible
        window.Visible=visible
    end

    -- Match the original floating button's tap/drag distinction.
    local pointer,origin,start,moved
    local function place(x,y)
        local bounds=gui.AbsoluteSize
        local size=launcher.AbsoluteSize
        if bounds.X<=0 or bounds.Y<=0 then return end
        local half=size.Y/2
        launcher.Position=UDim2.fromOffset(
            math.clamp(x,0,math.max(0,bounds.X-size.X)),
            math.clamp(y,math.min(half,bounds.Y/2),math.max(bounds.Y-half,bounds.Y/2)))
    end
    launcher.InputBegan:Connect(function(input)
        local kind=input.UserInputType
        if kind~=Enum.UserInputType.Touch and kind~=Enum.UserInputType.MouseButton1 then return end
        if pointer then return end
        pointer=input
        origin=input.Position
        start=launcher.AbsolutePosition-gui.AbsolutePosition+Vector2.new(0,launcher.AbsoluteSize.Y/2)
        moved=false
    end)
    local changed=UserInputService.InputChanged:Connect(function(input)
        if not pointer then return end
        if pointer.UserInputType==Enum.UserInputType.Touch then
            if input~=pointer then return end
        elseif input.UserInputType~=Enum.UserInputType.MouseMovement then return end
        local delta=input.Position-origin
        if not moved and delta.Magnitude<6 then return end
        moved=true
        place(start.X+delta.X,start.Y+delta.Y)
    end)
    local ended=UserInputService.InputEnded:Connect(function(input)
        if pointer and (input==pointer or
            (pointer.UserInputType==Enum.UserInputType.MouseButton1 and input.UserInputType==Enum.UserInputType.MouseButton1))then
            pointer=nil
        end
    end)
    local boundsChanged=gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        local pos=launcher.AbsolutePosition-gui.AbsolutePosition
        place(pos.X,pos.Y+launcher.AbsoluteSize.Y/2)
    end)
    launcher.Activated:Connect(function()
        if not moved then setWindowVisible(not window.Visible) end
    end)
    minimize.Activated:Connect(function()
        setWindowVisible(false)
    end)
    gui.Destroying:Connect(function()
        changed:Disconnect()
        ended:Disconnect()
        boundsChanged:Disconnect()
    end)
    setWindowVisible(false)
end
-- v33: Classic Minimal confirmation. Separate overlay remains usable
-- even when the main window is collapsed or dragged near the screen edge.
do
    local backdrop=new("TextButton",{
        Name="CloseConfirmationOverlay",Size=UDim2.fromScale(1,1),
        BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=1,
        BorderSizePixel=0,Text="",AutoButtonColor=false,Active=true,
        Selectable=false,Visible=false,ZIndex=100,
    },gui)
    local host=new("Frame",{
        Name="CloseConfirmationHost",AnchorPoint=Vector2.new(.5,.5),
        Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(420,212),
        BackgroundTransparency=1,BorderSizePixel=0,ZIndex=101,
    },backdrop)
    local responsiveScale=new("UIScale",{Scale=1},host)
    local dialog=new("Frame",{
        Name="CloseConfirmationDialog",AnchorPoint=Vector2.new(.5,.5),
        Position=UDim2.fromScale(.5,.5),Size=UDim2.fromScale(1,1),
        BackgroundColor3=C.slot,BorderSizePixel=0,Active=true,ZIndex=102,
    },host)
    corner(dialog,10)
    stroke(dialog,C.line,.32,1)
    local appearScale=new("UIScale",{Scale=1},dialog)
    new("TextLabel",{
        Name="Title",Position=UDim2.fromOffset(20,14),Size=UDim2.fromOffset(380,38),
        BackgroundTransparency=1,Text="Закрыть HORIZON?",TextColor3=C.text,
        Font=Enum.Font.GothamBold,TextSize=28,
        TextXAlignment=Enum.TextXAlignment.Left,ZIndex=103,
    },dialog)
    new("TextLabel",{
        Name="Description",Position=UDim2.fromOffset(20,61),Size=UDim2.fromOffset(380,52),
        BackgroundTransparency=1,Text="Вы действительно хотите закрыть интерфейс?",
        TextColor3=Color3.fromRGB(180,181,188),Font=Enum.Font.Gotham,
        TextSize=21,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,
        TextYAlignment=Enum.TextYAlignment.Top,ZIndex=103,
    },dialog)
    new("Frame",{
        Name="Divider",Position=UDim2.fromOffset(20,126),Size=UDim2.fromOffset(380,1),
        BackgroundColor3=C.line,BackgroundTransparency=.45,BorderSizePixel=0,ZIndex=103,
    },dialog)
    local function action(name,caption,x,color)
        local button=new("TextButton",{
            Name=name,AnchorPoint=Vector2.new(.5,.5),
            Position=UDim2.fromOffset(x,167),Size=UDim2.fromOffset(184,50),
            BackgroundColor3=color,BorderSizePixel=0,Text=caption,
            TextColor3=C.text,Font=Enum.Font.GothamMedium,TextSize=23,
            AutoButtonColor=false,ZIndex=104,
        },dialog)
        corner(button,8)
        return button
    end
    local cancel=action("Cancel","Отмена",112,Color3.fromRGB(69,71,77))
    local confirm=action("Confirm","Закрыть",308,Color3.fromRGB(87,49,55))
    local busy=false
    local function fitDialog()
        local bounds=backdrop.AbsoluteSize
        if bounds.X<=0 or bounds.Y<=0 then return end
        local scale=math.min(uiScale.Scale,math.max(.1,(bounds.X-24)/420),math.max(.1,(bounds.Y-24)/212))
        responsiveScale.Scale=scale
        local center=window.AbsolutePosition+window.AbsoluteSize/2-backdrop.AbsolutePosition
        local halfW,halfH=210*scale,106*scale
        host.Position=UDim2.fromOffset(
            math.clamp(center.X,halfW,bounds.X-halfW),
            math.clamp(center.Y,halfH,bounds.Y-halfH))
    end
    backdrop:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitDialog)
    uiScale:GetPropertyChangedSignal("Scale"):Connect(fitDialog)
    window:GetPropertyChangedSignal("AbsolutePosition"):Connect(fitDialog)
    window:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitDialog)
    local function animate(transparency,scale,duration)
        local info=TweenInfo.new(duration,Enum.EasingStyle.Sine,Enum.EasingDirection.Out)
        TweenService:Create(backdrop,info,{BackgroundTransparency=transparency}):Play()
        TweenService:Create(appearScale,info,{Scale=scale}):Play()
    end
    local function finish(shouldClose)
        if busy or not backdrop.Visible then return end
        busy=true
        animate(1,.94,.20)
        task.delay(.24,function()
            if not gui.Parent then return end
            if shouldClose then
                -- Preserve the original shutdown path; only confirmation invokes it.
                if viewportConnection then viewportConnection:Disconnect() end
                if cameraConnection then cameraConnection:Disconnect() end
                gui:Destroy()
            else
                backdrop.Visible=false
                busy=false
            end
        end)
    end
    softPreview(cancel,function() finish(false) end)
    softPreview(confirm,function() finish(true) end)
    close.MouseButton1Click:Connect(function()
        if busy or backdrop.Visible or not gui.Parent then return end
        dragging=false
        dragInput=nil
        dragStart=nil
        backdrop.BackgroundTransparency=1
        appearScale.Scale=.94
        fitDialog()
        backdrop.Visible=true
        animate(.40,1,.20)
    end)
end
