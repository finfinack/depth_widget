import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Sensor;

class depthView extends WatchUi.View {

    const depth_label = "Depth";
    const max_depth_label = "Max Depth";

    const feet_per_meter = 3.28084;
    const water_pressure = 9806.65; // pascal per meter

    private var start_pressure;
    private var max_depth_value = 0.0;
    private var max_depth = "n/a";
    private var depth = "n/a";

    var unit; // System.UNIT_METRIC or System.UNIT_STATUTE

    function initialize() {
        View.initialize();

        unit = System.getDeviceSettings().heightUnits;
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        self.updateDepth(Sensor.getInfo());
        // Request a redraw when the widget is shown
        WatchUi.requestUpdate();
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        // View.onUpdate(dc);

        var labelFont = Graphics.FONT_SMALL;
        var valueFont = Graphics.FONT_LARGE;

        var width = dc.getWidth();
        var height = dc.getHeight();

        var labelDepthY = height / 7;
        var depthY = (height / 7) * 2;
        var labelMaxDepthY = (height / 7) * 4;
        var maxDepthY = (height / 7) * 5;

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, labelDepthY, labelFont, depth_label, Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(width / 2, depthY, valueFont, depth, Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(width / 2, labelMaxDepthY, labelFont, max_depth_label, Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(width / 2, maxDepthY, valueFont, max_depth, Graphics.TEXT_JUSTIFY_CENTER);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    function updateDepth(info as Sensor.Info) {
        // See Activity.Info in the documentation for available information.
        // - altitude as Lang.Float or Null
        //   The altitude above mean sea level in meters (m).
        // - ambientPressure as Lang.Float or Null
        //   The ambient pressure in Pascals (Pa).
        // - rawAmbientPressure as Lang.Float or Null
        //   The raw ambient pressure in Pascals (Pa).
        var current_pressure = info.pressure;
        if (start_pressure == null) {
            start_pressure = current_pressure;
        }

        if (current_pressure == null || start_pressure == null) {
            self.depth = "n/a";
            self.max_depth = "n/a";
            return;
        }
        // Recalibrate if the watch seems to be out of water.
        if (start_pressure > current_pressure) {
            start_pressure = current_pressure;
        }

        var pressure_diff = current_pressure - start_pressure;
        var depth = pressure_diff/water_pressure;
        if (unit == System.UNIT_METRIC) {
            self.depth = depth.format("%.2f");
        } else {
            self.depth = (depth*feet_per_meter).format("%1f");
        }

        if (depth > self.max_depth_value) {
            self.max_depth_value = depth;
        }
        if (unit == System.UNIT_METRIC) {
            self.max_depth = self.max_depth_value.format("%.2f");
        } else {
            self.max_depth = (self.max_depth_value*feet_per_meter).format("%1f");
        }
    }

}
