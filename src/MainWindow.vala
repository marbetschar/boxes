/*
* Copyright 2019 elementary, Inc. (https://elementary.io)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
*/

[GtkTemplate (ui = "/com/github/marbetschar/boxes/ui/MainWindow.glade")]
public class Boxes.MainWindow : Gtk.ApplicationWindow {

    private uint configure_id;
    private AddContainerAssistant add_container_assistant;

    [GtkChild]
    private Gtk.Viewport viewport;

    [GtkChild]
    private Gtk.Button remove_button;

    public MainWindow (Gtk.Application application) {
        Object (
            application: application,
            icon_name: "com.github.marbetschar.boxes",
            title: _("Boxes")
        );
    }

    construct {
        var style_provider = new Gtk.CssProvider ();
        style_provider.load_from_resource ("/com/github/marbetschar/boxes/styles/Application.css");
        Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), style_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        var list_box = new Boxes.Widgets.ContainerListBox ();

        viewport.add (list_box);

        list_box.row_selected.connect ((row) => {
            remove_button.sensitive = row != null;
        });

        var containers = Application.lxd_client.get_containers ();

        debug (@"[name = $(containers[0].name), status = $(containers[0].status)]");
    }

    [GtkCallback]
    private void on_add_button_clicked (Gtk.Widget source) {
        if (add_container_assistant == null) {
            add_container_assistant = new AddContainerAssistant ();
            add_container_assistant.destroy.connect (() => {
                add_container_assistant = null;
            });
        }
        add_container_assistant.present ();
    }

    [GtkCallback]
    private void on_remove_button_clicked (Gtk.Widget source) {
        debug ("on_remove_button_clicked");
    }

    public override bool configure_event (Gdk.EventConfigure event) {
        if (configure_id != 0) {
            GLib.Source.remove (configure_id);
        }

        configure_id = Timeout.add (100, () => {
            configure_id = 0;

            Gdk.Rectangle rect;
            get_allocation (out rect);
            Boxes.Application.settings.set ("window-size", "(ii)", rect.width, rect.height);

            int root_x, root_y;
            get_position (out root_x, out root_y);
            Boxes.Application.settings.set ("window-position", "(ii)", root_x, root_y);

            return false;
        });

        return base.configure_event (event);
    }
}
