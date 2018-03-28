#!/bin/bash

consul agent -dev &

basht tests/lib.consul.sh
