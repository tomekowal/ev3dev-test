#!/bin/bash

# This program shows, how to use lego ev3 tacho motor and touch sensor
# Pressing the button will slowly increase the motor speed, while releasing it
# will set the speed to zero, which will let the motor naturally stop

# Both tacho motor and touch sensor are mounted at /sys/class/...
# The numbers at the end have nothing to do with actual port,
# you plugged them into.
# This number is incremented every time, you connect new device with given type
# or unplug and plug back the device.
# TODO: Change those, if necesarry.
MOTOR=/sys/class/tacho-motor/motor0
TOUCH_SENSOR=/sys/class/lego-sensor/sensor0

# The motor can run in UNREGULATED mode, where it just receives
# some voltage and can be stopped, when you apply pressure
# or in REGULATED mode, where applying pressure is compensated by higher power
# to preserve speed even under load.
function init {
    echo on > $MOTOR/regulation_mode
    echo 0 > $MOTOR/pulses_per_second_sp
    echo 1 > $MOTOR/run
}

# Read the value of touch sensor, if it is pressed - accelerate
# if it is not pressed - set speed to 0
function loop {
    # In touch sensor only value0 has meaningful data
    RUN=`cat $TOUCH_SENSOR/value0`
    # Just for debugging echo the touch sensor output
    # 1 means button pressed
    # 0 means button released
    echo $RUN
    case $RUN in
        1 )
            # Read the current speed, add 25 and write it back
            # Max for tacho motor is 1200, so it will be at full speed 
            # after 24 iterations
            SPEED=`cat $MOTOR/pulses_per_second_sp`
            NEW_SPEED=$((SPEED + 25))
            echo $NEW_SPEED
            echo $NEW_SPEED > $MOTOR/pulses_per_second_sp ;;
        0 )
            echo 0 > $MOTOR/pulses_per_second_sp ;;
    esac
}

init
while true 
do
    loop
    sleep 0.1s
done
