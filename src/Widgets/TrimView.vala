namespace Trimmer {
    public class TrimView : Gtk.Box {
        public unowned Trimmer.Window window {get; set;}
        public Trimmer.Timeline timeline {get; set;}
        private Trimmer.MessageArea message_area;
        public Trimmer.VideoPlayer video_player;
        public Granite.SeekBar seeker;
        public Trimmer.Controllers.TrimController trim_controller;

        private Gtk.Button play_button;
        private Trimmer.TimeStampEntry start_entry;
        private Trimmer.TimeStampEntry end_entry;
        private Gtk.Button trim_button;

        public TrimView (Trimmer.Window window) {
            Object (
                orientation: Gtk.Orientation.VERTICAL,
                spacing: 0,
                window: window
            );
        }

        construct {
            create_layout ();

            play_button.clicked.connect (() => {
                window.actions.lookup_action (Window.ACTION_PLAY_PAUSE).activate (null);
            });

            video_player.video_loaded.connect((duration, uri) => {
                timeline.playback_duration = duration;
                trim_controller.duration = duration;
                trim_controller.video_uri = uri;
            });

            timeline.bind_property (
                "start-time",
                trim_controller,
                "trim-start-time",
                BindingFlags.BIDIRECTIONAL
            );

            timeline.bind_property (
                "end-time",
                trim_controller,
                "trim-end-time",
                BindingFlags.BIDIRECTIONAL
            );

            start_entry.bind_property (
                "time",
                trim_controller,
                "trim-start-time",
                BindingFlags.BIDIRECTIONAL
            );

            end_entry.bind_property (
                "time",
                trim_controller,
                "trim-end-time",
                BindingFlags.BIDIRECTIONAL
            );

            trim_controller.notify ["is-valid-trim"].connect (() => {
                start_entry.is_valid = trim_controller.is_valid_trim;
                end_entry.is_valid = trim_controller.is_valid_trim;
                trim_button.sensitive = trim_controller.is_valid_trim;
            });

            trim_controller.trim_failed.connect ((message) => {
                message_area.add_message (Gtk.MessageType.ERROR, message);
            });

            trim_controller.trim_success.connect ((message) => {
                // TODO: Implement a handler for this to give some feedback to 
                // the user. Perhaps a toast.
            });

            trim_button.clicked.connect (trim_controller.trim);
        }

        private void create_layout () {
            message_area = new MessageArea ();
            video_player = new VideoPlayer (this);
            trim_controller = new Controllers.TrimController ();

            var timeline_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                valign = Gtk.Align.CENTER
            };
            play_button = new Gtk.Button.from_icon_name ("media-playback-pause-symbolic");

            timeline = new Timeline (video_player);
            timeline_box.pack_start (play_button, false, false, 0);
            timeline_box.pack_start (timeline, false, true, 0);

            var button_box = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL) {
                layout_style = Gtk.ButtonBoxStyle.END
            };

            trim_button = new Gtk.Button.with_label ("Trim") {
                margin = 5
            };
            trim_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
            button_box.pack_end (trim_button);

            var start_end_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                margin_top = 10,
                halign = Gtk.Align.CENTER
            };

            var start_label = new Gtk.Label ("Start");
            var end_label = new Gtk.Label ("End");

            start_entry = new Trimmer.TimeStampEntry ();
            end_entry = new Trimmer.TimeStampEntry ();

            start_end_box.pack_start (start_label, false, false, 10);
            start_end_box.pack_start (start_entry, false, false, 10);
            start_end_box.pack_start (end_label, false, false, 10);
            start_end_box.pack_start (end_entry, false, false, 10);

            pack_start (message_area, false, false, 0);
            pack_start (video_player, true, true, 0);
            pack_start (timeline_box, false, false, 0);
            pack_start (start_end_box, false, false, 0);
            pack_start (button_box, false, false, 0);
        }
        
        public void update_play_button_icon () {
            if (video_player.playback.playing) {
                ((Gtk.Image) play_button.image).icon_name = "media-playback-pause-symbolic";
            } else {
                ((Gtk.Image) play_button.image).icon_name = "media-playback-start-symbolic";
            }
        }
    }
}
