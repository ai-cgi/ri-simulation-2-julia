using ImageView, Images, TestImages, Gtk, Plots

b_start = GtkButton("Start")
b_stop = GtkButton("Stop")
c_iterations = GtkScale(false,1:10000)

x = ["Completed", "Remaining"]
y = [100, 1000]
status_plot = pie(x, y, title = "Running Status", l = 0.5, fmt = :png)
savefig(status_plot,"running_status.png")

reward_plot = plot(x, y, title = "Reward Status", l = 0.5, fmt = :png)
savefig(reward_plot,"reward_status.png")

frame, c = ImageView.frame_canvas(:auto)
frame2, d = ImageView.frame_canvas(:auto)
frame3, e = ImageView.frame_canvas(:auto)

g = GtkGrid()
g[1:5,1:2] = frame
g[6:8,1] = frame2
g[6:8,2] = frame3

g[3,2] = GtkLabel(" ")
g[3,3] = GtkLabel("Number of Iterations")

g[1,4] = b_start
g[2:4,4] = c_iterations
g[5,4] = b_stop

win = GtkWindow("New Advanced Reinforcement Learning GUI", 1024,576)
push!(win, g)
Gtk.showall(win)

background_img = load("resources/background.png")
running_status_img = load("running_status.png")
reward_status_img = load("reward_status.png")
imshow(c, background_img)
imshow(d, running_status_img)   
imshow(e, reward_status_img)   