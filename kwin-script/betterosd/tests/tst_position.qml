import QtQuick
import QtTest
import "../contents/code/main.js" as Main

TestCase {
    name: "computePosition"

    property var area: ({ x: 0, y: 0, width: 1920, height: 1160 })
    property var size: ({ width: 400, height: 80 })

    function test_anchors_data() {
        return [
            { tag: "TopLeft", anchor: 0, x: 20, y: 30 },
            { tag: "TopCenter", anchor: 1, x: 760, y: 30 },
            { tag: "TopRight", anchor: 2, x: 1500, y: 30 },
            { tag: "CenterLeft", anchor: 3, x: 20, y: 540 },
            { tag: "Center", anchor: 4, x: 760, y: 540 },
            { tag: "CenterRight", anchor: 5, x: 1500, y: 540 },
            { tag: "BottomLeft", anchor: 6, x: 20, y: 1050 },
            { tag: "BottomCenter", anchor: 7, x: 760, y: 1050 },
            { tag: "BottomRight", anchor: 8, x: 1500, y: 1050 }
        ];
    }

    function test_anchors(data) {
        var pos = Main.computePosition(area, size, data.anchor, 20, 30);

        compare(pos.x, data.x);
        compare(pos.y, data.y);
    }

    function test_zeroMargins_areFlushWithEdges() {
        var pos = Main.computePosition(area, size, 8, 0, 0);

        compare(pos.x, 1520);
        compare(pos.y, 1080);
    }

    function test_areaOrigin_isRespected() {
        var second = { x: 1920, y: 40, width: 2560, height: 1400 };

        var pos = Main.computePosition(second, size, 0, 10, 10);

        compare(pos.x, 1930);
        compare(pos.y, 50);
    }

    function test_oddCenter_isRounded() {
        var pos = Main.computePosition({ x: 0, y: 0, width: 1001, height: 1001 }, size, 4, 0, 0);

        compare(pos.x, 301);
        compare(pos.y, 461);
    }

    function test_hugeMargin_isClampedIntoArea() {
        var topLeft = Main.computePosition(area, size, 0, 5000, 5000);
        var bottomRight = Main.computePosition(area, size, 8, 5000, 5000);

        compare(topLeft.x, 1520);
        compare(topLeft.y, 1080);
        compare(bottomRight.x, 0);
        compare(bottomRight.y, 0);
    }

    function test_osdLargerThanArea_sticksToAreaStart() {
        var pos = Main.computePosition({ x: 100, y: 100, width: 300, height: 50 }, size, 8, 0, 0);

        compare(pos.x, 100);
        compare(pos.y, 100);
    }
}
