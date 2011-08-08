package com.apexinnovations.transwarp.ui {

import mx.core.IFlexDisplayObject;
import mx.managers.IFocusManagerContainer;
import spark.components.Group;
import com.apexinnovations.transwarp.utils.TranswarpVersion;

TranswarpVersion.revision = "$Rev$";

public class FocusGroup extends Group implements IFocusManagerContainer
{
    public function get defaultButton():IFlexDisplayObject
    {
        return null;    
    }
    public function set defaultButton(value:IFlexDisplayObject):void
    {
        
    }
    
}

}
