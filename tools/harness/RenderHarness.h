#pragma once

class QGuiApplication;
class QQmlApplicationEngine;

namespace bv {

// Installs the message recorder. Must run before the QML engine loads so that
// load-time warnings are captured.
void installHarnessMessageHandler();

// Drives the loaded app through the page matrix in BV_HARNESS_PAGES, writing a
// PNG plus an item-tree JSON per page into BV_HARNESS_OUT, then quits.
void runRenderHarness(QQmlApplicationEngine& engine, QGuiApplication& app);

}
