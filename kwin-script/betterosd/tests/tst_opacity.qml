import QtQuick
import QtTest
import "../contents/code/main.js" as Main

TestCase {
    name: "opacityFromPercent"

    function test_percentMapsToFraction() {
        compare(Main.opacityFromPercent(100), 1);
        compare(Main.opacityFromPercent(75), 0.75);
    }

    function test_stringFromConfig() {
        compare(Main.opacityFromPercent("50"), 0.5);
    }

    function test_clampsToVisibleRange() {
        compare(Main.opacityFromPercent(0), 0.1);
        compare(Main.opacityFromPercent(250), 1);
    }

    function test_garbageIsOpaque() {
        compare(Main.opacityFromPercent("x"), 1);
        compare(Main.opacityFromPercent(undefined), 1);
    }
}
