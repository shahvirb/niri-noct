local zones = {
    { label = "AUSTIN", zone = "America/Chicago" },
    { label = "BANGALORE", zone = "Asia/Kolkata" },
    { label = "DEBRECEN", zone = "Europe/Budapest" },
    { label = "PENANG", zone = "Asia/Kuala_Lumpur" },
}

local function render()
    local rows = {}

    for _, city in ipairs(zones) do
        table.insert(rows, ui.row({ gap = 14, align = "center" }, {
            ui.label({
                text = city.label,
                width = 110,
                fontWeight = "bold",
                color = "primary",
            }),
            ui.label({
                text = noctalia.formatTime("{:%H:%M}", nil, city.zone),
                fontSize = 22,
                color = "on_surface",
            }),
        }))
    end

    desktopWidget.render(ui.column({ gap = 8, align = "start", fill = "#00000000" }, rows))
end

function update()
    desktopWidget.setWantsSecondTicks(true)
    render()
end
