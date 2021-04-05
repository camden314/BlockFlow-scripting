#cython: language_level=3
#distutils: language = c++
from base cimport *

cdef public class Editor(PyCCObject) [object PyEditorUI, type PyEditUI]:

    cdef EditorUI* edit_inst(self):
        return <EditorUI*>self.inst
    def __init__(self):
        self.inst = <CCObject*>EditorUI_shared()
    @thread_async
    def pasteStr(self, obs):
        if type(obs)==str:
            obs = obs.encode()
        self.edit_inst().pasteObjects(obs)

    @thread_sync
    def createObject(self, objectid, x=0.0, y=0.0):
        objectid = int(objectid)
        cdef CCPoint p
        p.x = float(x)
        p.y = float(y)+90.0

        cdef GameObject* o = self.edit_inst()._editorLayer().createObject(objectid, p, True)
        pyo = PyGameObject().fromPtr(<CCObject*>o)
        return pyo

    @property
    def selection(self):
        cdef CCArray* sel = self.edit_inst().getSelectedObjects()
        c = GameObjArray().fromPtr(sel)
        return c

    def deselect(self):
        self.edit_inst().deselectAll()

    @thread_sync
    def duplicate(self):
        self.edit_inst().onDuplicate(<CCObject*>self.edit_inst())
        return self.selection

    @selection.setter
    def selection(self, objects):
        cdef GameObjArray ccar = GameObjArray().init(objects)
        self.edit_inst().selectObjects(ccar.arr_inst(), False)

    def select(self, object_s):
        if issubclass(type(object_s), PyGameObject):
            object_s = [object_s]
        cdef GameObjArray ccar = GameObjArray().init(object_s)
        self.edit_inst().selectObjects(ccar.arr_inst(), True)