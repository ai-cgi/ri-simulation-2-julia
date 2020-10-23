using ImageView, Images, TestImages, Gtk.ShortNames

# create the background image level 1
background_img = load("resources/background.png")

simulation_img = background_img

# create the environment image Level 2
labyrinth_img = load("resources/labyrinth.png")

# create the environment image Level 3
reward_img = load("resources/reward.png")

# create the agent image level 4
agent_img = load("resources/agent-green-small.png")

canvassize = (1024,576)
gui = imshow_gui(canvassize)
canvases = gui["canvas"]

"Overlays image over other image

# Arguments
- org_img, original image
- overlay_img, the image that should be overlayed
- offset, the offset to overlay
"
function overlay_image(org_img, overlay_img, offset)
    size_x = first(size(overlay_img))
    size_y = last(size(overlay_img))

    for x = 1:size_x
        for y = 1:size_y
            if overlay_img[x,y].r > 0 || overlay_img[x,y].g > 0 || overlay_img[x,y].b > 0
                org_img[x+offset.y,y+offset.x] = overlay_img[x,y]
            end
        end
    end
end


function calculate_environment_offset(pad_x, pad_y, env)
    env_max_x = size(env)[1]-45
    env_max_y = size(env)[2]-130

    # environment_size is hardcoded
    step_size_x = env_max_x / 10
    step_size_y = env_max_y / 10

    env_offset = EnvironmentOffset(pad_x, pad_y, round(step_size_x), round(step_size_y))
end

"Calculate the absolute pixel offsets for the simulation based on the relativ position of
sprite and environment."
function calculate_gui_offset(env_offset, sprite, pos_x, pos_y)
    sprite_max_x = size(sprite)[1]
    sprite_max_y = size(sprite)[2]

    offset_x = env_offset.pad_x + ((pos_x - 1) * env_offset.step_x) + ((env_offset.step_x - sprite_max_x) / 2)
    offset_y = env_offset.pad_y + ((pos_y - 1) * env_offset.step_y) + ((env_offset.step_y - sprite_max_y) / 2)

    offset = Offset(round(offset_x), round(offset_y))
end

function initialize_gui(rewards, agent)

    labyrinth_offset = Offset(250,80)

    overlay_image(background_img, labyrinth_img, labyrinth_offset)
    env_offsets = calculate_environment_offset(275,115, labyrinth_img)

    imshow(canvases, background_img)
    Gtk.showall(gui["window"])

    return env_offsets
end

# some fixes needed actual all is repainted
function update_gui(env_offsets, rewards, agent)

    simulation_img = copy(background_img)

    for r in rewards
     r.gui_offset = calculate_gui_offset(env_offsets, reward_img, r.sim_offset.x, r.sim_offset.y)
     overlay_image(simulation_img, reward_img, r.gui_offset)
    end

    agent.gui_offset = calculate_gui_offset(env_offsets, agent_img, agent.sim_offset.x, agent.sim_offset.y)
    overlay_image(simulation_img, agent_img, agent.gui_offset)

    imshow(canvases, simulation_img)
    Gtk.showall(gui["window"])
end
