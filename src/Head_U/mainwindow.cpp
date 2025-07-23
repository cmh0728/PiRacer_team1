#include "rpm_calculate.h"
#include "mainwindow.h"
#include "ui_mainwindow.h"
#include <QDebug>

CANReceiver *canReceiver = nullptr;

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
{
    ui->setupUi(this);

    canReceiver = new CANReceiver(this);

    // RPM 수신 시 LCD 업데이트
    connect(canReceiver, &CANReceiver::rpmReceived, this, [=](int rpm) {
        ui->lcdNumber->display(rpm);
    });

    canReceiver->start();
}

MainWindow::~MainWindow()
{
    delete ui;
}
