import flash.utils.Dictionary;

protected var _references:Dictionary = new Dictionary();
protected var _referenceCount:int = 0;
protected var _pendingFlush:Boolean = false;

public function addReference(referrer :*):void {
	if(referrer  in _references)
		return;
	_references[referrer] = true;
	_referenceCount++;
		
}

public function releaseReference(referrer :*):void {
	if(referrer in _references) {
		delete _references[referrer];
		_referenceCount--;
	}
}

public function get referenceCount():int { 
	return _referenceCount; 
}

public function get pendingFlush():Boolean { return _pendingFlush; }
public function set pendingFlush(value:Boolean):void { _pendingFlush = value; }