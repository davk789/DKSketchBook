DKBufferUtils {
	/*
		Disorganized collections of static functions designed to allow for quicker
		buffer management for various livecoding applications.
	*/
	*checkConditions { |function|
		/* These functions all need to be called from a routine, when the server is
		running, in order for the sync messages to work, and for the buffers to have
		some place to go. */

		
		if(Server.default.serverRunning.not){
			error("launch the server dummy!");
			throw(function);
			//			^nil;
		};

		if(thisThread.isKindOf(Routine).not){
			error("this function needs to be called from a routine (sorry)");
			throw(function);
			//^nil;
		};
		
	}
	
	*loadIRBuffer { |filePath, fftsize=2048|
		// prepare a buffer for use with the PartConv UGen -- for reverb from
		// impulse response, but can also be used for convolution

		var srcBuf, irBuf, bufSize;

		this.checkConditions(thisMethod);
		
		// these functions must be called from a fork, the function itself
		// can not do this
		//		fork{
		srcBuf = Buffer.read(Server.default, filePath);
		
		Server.default.sync; // wait until finished loading?
		
		bufSize = PartConv.calcBufSize(fftsize, srcBuf);
		irBuf = Buffer.alloc(Server.default, bufSize, 1);
		irBuf.preparePartConv(srcBuf, fftsize);
		Server.default.sync;
		//srcBuf.plot;
		//irBuf.plot;
		srcBuf.free;
		^irBuf;
		//		};

		
	}

	*prepareOddPowerWavetables { |numBuffers=8| // more than 8 it becomes hard to tell the difference
		/* It would be nice to be able to work with the VOsc directly, but for now,
		just return the formatted buffers. */
		
		// there is still a problem with the math, as well as the buffer
		// access, but this is close
		var signals, buffers;

		this.checkConditions(thisMethod);
		
		signals = Array.fill(numBuffers, { |ind|
			Signal.fill(1024, { |i|
				var val = (i / 1024) * 2pi;
				sin(val).pow((ind * 2) + 1);
			}).asWavetable
		});

		/* the buffer size can be as low as 2046, not sure how the math works, but this
		sounds close enough. */
		buffers = Buffer.allocConsecutive(numBuffers, Server.default, 2048, 1);

		Server.default.sync;

		buffers.do{ |obj,ind|
			obj.loadCollection(signals[ind]);
		};

		^buffers;
	}
}

