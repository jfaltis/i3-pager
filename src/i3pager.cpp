#include <i3ipc++/ipc.hpp>
#include "i3pager.h"
#include <QScreen>
#include <QGuiApplication>
#include <QApplication>
#include <QDesktopWidget>
#include <QDebug>
#include <future>
#include <QVariant>

#include <QtConcurrent/QtConcurrent>


I3Pager::I3Pager(QObject *parent) : QObject(parent) {
    currentScreenPrivate = QString();
    mode = "default";
    QtConcurrent::run(QThreadPool::globalInstance(), [this]() {
        while (true) {
            handleI3Events();
            qWarning() << "Lost ipc connection";
            QThread::sleep(10);
        }
    });
}

void I3Pager::handleI3Events() {
    try {
        i3ipc::connection conn;
        conn.subscribe(i3ipc::ET_WORKSPACE | i3ipc::ET_BINDING | i3ipc::ET_MODE);
        // Handler of WORKSPACE EVENT
        conn.signal_workspace_event.connect([this](const i3ipc::workspace_event_t&  ev) {
            qInfo() << "workspace_event: " << (char)ev.type;
            if (ev.current) {
                qInfo() << "\tSwitched to #" << ev.current->num << " - \"" << QString::fromStdString(ev.current->name) << '"';
                Q_EMIT currentScreenChanged();
            }
        });

        conn.signal_mode_event.connect([this](const i3ipc::mode_t& mode) {
            this->mode = QString::fromStdString(mode.change);
            qInfo() << "mode: " << this->mode;
            Q_EMIT modeChanged();
        });

        while (true) {
            conn.handle_event();
        }
    } catch (...) {
        // TODO
        qWarning() << "i3ipc error";
    }
}

QVariantList I3Pager::getWorkspaces() {
    QVariantList dataList;
    try {
        i3ipc::connection conn;
        qInfo() << "Screen name " << this->currentScreenPrivate;
        auto workspaces = conn.get_workspaces();
        for (auto& workspace : workspaces) {
            qInfo() << "name " << QString::fromStdString(workspace->name);
            qInfo() << "out " << QString::fromStdString(workspace->output);
            if(QString::fromStdString(workspace->output) == this->currentScreenPrivate) {
                QMap<QString, QVariant> workspaceData;
                auto wsName = QString::fromStdString(workspace->name);
                auto splitName = wsName.split(':');
                auto index = splitName[0];
                auto name = splitName.size() == 1 ? splitName[0] : splitName[1];
                auto icon = splitName.size() == 3 ? splitName[2] : "";

                workspaceData.insert("id", wsName);
                workspaceData.insert("index", index);
                workspaceData.insert("name", name);
                workspaceData.insert("icon", icon);
                workspaceData.insert("visible", workspace->visible);
                workspaceData.insert("urgent", workspace->urgent);

                dataList.append(workspaceData);
            }
        }
    } catch (...) {
        // TODO
    }
    return dataList;
}

void I3Pager::activateWorkspace(QString workspace) {
    i3ipc::connection conn;
    conn.send_command("workspace " + workspace.toStdString());
}

void I3Pager::setCurrentScreen(QString screen) {
    this->currentScreenPrivate = screen;
    Q_EMIT currentScreenChanged();
}

QString I3Pager::getMode() {
    return mode;
}
