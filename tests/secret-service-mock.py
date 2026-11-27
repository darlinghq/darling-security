#!/usr/bin/env python3
# Copyright (C) 2026 Lubos Dolezel
#
# A minimal freedesktop Secret Service for secret-service-backend.py: it owns
# org.freedesktop.secrets on the bus at <address>, supports only the "plain"
# session algorithm (any other one is refused with
# org.freedesktop.DBus.Error.NotSupported, as the Secret Service API specifies
# for an unsupported algorithm), keeps its items in memory in one always
# unlocked collection that is the "default" alias, and writes its state as JSON
# to <state file> after every call: the algorithms that OpenSession was asked
# for, in order, and every item's attributes, label and secret (hex).
#
# usage: secret-service-mock.py <address> <state file>
#
# Needs dbus-python and PyGObject (GLib main loop).

import json
import os
import sys

import dbus
import dbus.mainloop.glib
import dbus.service
from gi.repository import GLib

SERVICE_IFACE = "org.freedesktop.Secret.Service"
COLLECTION_IFACE = "org.freedesktop.Secret.Collection"
ITEM_IFACE = "org.freedesktop.Secret.Item"
PROPS_IFACE = "org.freedesktop.DBus.Properties"
ROOT = "/org/freedesktop/secrets"
COLLECTION = ROOT + "/collection/mock"

address, state_path = sys.argv[1], sys.argv[2]
dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
bus = dbus.bus.BusConnection(address)

algorithms = []
sessions = set()
items = {}
next_id = [1]


class NotSupported(dbus.DBusException):
    _dbus_error_name = "org.freedesktop.DBus.Error.NotSupported"


class NoSession(dbus.DBusException):
    _dbus_error_name = "org.freedesktop.Secret.Error.NoSession"


class NoSuchObject(dbus.DBusException):
    _dbus_error_name = "org.freedesktop.Secret.Error.NoSuchObject"


def save():
    state = {"algorithms": algorithms,
             "items": [{"attributes": dict(i.attributes), "label": i.label, "secret": i.secret.hex()}
                       for i in items.values()]}
    tmp = state_path + ".tmp"
    with open(tmp, "w") as f:
        json.dump(state, f)
    os.replace(tmp, state_path)


def take_secret(secret):
    session, parameters, value, _content_type = secret
    if str(session) not in sessions:
        raise NoSession("unknown session")
    if len(parameters) != 0:
        raise dbus.DBusException("a plain secret has no parameters",
                                 name="org.freedesktop.DBus.Error.InvalidArgs")
    return bytes(value)


class Item(dbus.service.Object):
    def __init__(self, path, attributes, label, secret):
        super().__init__(bus, path)
        self.path, self.attributes, self.label, self.secret = path, attributes, label, secret

    @dbus.service.method(ITEM_IFACE, in_signature="o", out_signature="(oayays)")
    def GetSecret(self, session):
        if str(session) not in sessions:
            raise NoSession("unknown session")
        return dbus.Struct((session, dbus.ByteArray(b""), dbus.ByteArray(self.secret), "text/plain"),
                           signature="oayays")

    @dbus.service.method(ITEM_IFACE, in_signature="(oayays)", out_signature="", byte_arrays=True)
    def SetSecret(self, secret):
        self.secret = take_secret(secret)
        save()

    @dbus.service.method(ITEM_IFACE, in_signature="", out_signature="o")
    def Delete(self):
        del items[self.path]
        self.remove_from_connection()
        save()
        return dbus.ObjectPath("/")

    @dbus.service.method(PROPS_IFACE, in_signature="ss", out_signature="v")
    def Get(self, interface, name):
        if name == "Attributes":
            return dbus.Dictionary(self.attributes, signature="ss")
        if name == "Label":
            return dbus.String(self.label)
        if name == "Locked":
            return dbus.Boolean(False)
        raise NoSuchObject(name)

    @dbus.service.method(PROPS_IFACE, in_signature="ssv", out_signature="")
    def Set(self, interface, name, value):
        if name == "Attributes":
            self.attributes = {str(k): str(v) for k, v in value.items()}
        elif name == "Label":
            self.label = str(value)
        else:
            raise NoSuchObject(name)
        save()


class Collection(dbus.service.Object):
    @dbus.service.method(COLLECTION_IFACE, in_signature="a{sv}(oayays)b", out_signature="oo", byte_arrays=True)
    def CreateItem(self, properties, secret, replace):
        value = take_secret(secret)
        attributes = {str(k): str(v) for k, v in properties.get(ITEM_IFACE + ".Attributes", {}).items()}
        label = str(properties.get(ITEM_IFACE + ".Label", ""))
        for item in items.values():
            if replace and item.attributes == attributes:
                item.label, item.secret = label, value
                save()
                return dbus.ObjectPath(item.path), dbus.ObjectPath("/")
        path = f"{COLLECTION}/{next_id[0]}"
        next_id[0] += 1
        items[path] = Item(path, attributes, label, value)
        save()
        return dbus.ObjectPath(path), dbus.ObjectPath("/")


class Service(dbus.service.Object):
    @dbus.service.method(SERVICE_IFACE, in_signature="sv", out_signature="vo")
    def OpenSession(self, algorithm, value):
        algorithms.append(str(algorithm))
        save()
        if algorithm != "plain":
            raise NotSupported("only the plain algorithm is supported")
        path = f"{ROOT}/session/{len(algorithms)}"
        sessions.add(path)
        return dbus.String(""), dbus.ObjectPath(path)

    @dbus.service.method(SERVICE_IFACE, in_signature="a{ss}", out_signature="aoao")
    def SearchItems(self, attributes):
        wanted = {str(k): str(v) for k, v in attributes.items()}
        found = [dbus.ObjectPath(p) for p, i in items.items()
                 if all(i.attributes.get(k) == v for k, v in wanted.items())]
        return dbus.Array(found, signature="o"), dbus.Array([], signature="o")

    @dbus.service.method(SERVICE_IFACE, in_signature="ao", out_signature="aoo")
    def Unlock(self, objects):
        return dbus.Array(objects, signature="o"), dbus.ObjectPath("/")

    @dbus.service.method(SERVICE_IFACE, in_signature="s", out_signature="o")
    def ReadAlias(self, name):
        return dbus.ObjectPath(COLLECTION if name == "default" else "/")


service = Service(bus, ROOT)
collection = Collection(bus, COLLECTION)
save()
name = dbus.service.BusName("org.freedesktop.secrets", bus)
GLib.MainLoop().run()
