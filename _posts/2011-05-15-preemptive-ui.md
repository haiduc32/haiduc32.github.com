---
layout: post
title: Preemptive UI
date: 2011-05-15 18:49:27.000000000 +03:00
categories:
- Concept
tags:
- preemptive ui
status: publish
type: post
published: true
post_id: preemtive-ui
meta:
  _networkpub_meta_published: new
  _edit_last: '1'
  _syntaxhighlighter_encoded: '1'
author:
  login: admin
  email: haiduc32@gmail.com
  display_name: Radu
  first_name: ''
  last_name: ''
---
<p>In some previous post I mentioned that I am a speed freak. The faster something (anything) runs the better. When I refer to very fast computers I say that they start doing something the moment you think about it. But how Sci-Fi is that? For some time an idea was hovering in my head and a few days ago, after I've put my head on the pillow, I got it.</p>
<p>How about if the program was actually starting to process some button action before you manage to click it? Consider a button that does some lengthy processing, for instance an image transformation. What if it started to process the image the moment you thought about that, and when you click the button for that action it just output the result (if you don't click the button assume you changed your mind on that and the transformations are not applied)?<!--more--></p>
<p>My dream came true on a lazy Sunday afternoon.</p>
<p>Well not fully.. we are still decades till neural sensors that could sense what we think, and then give up on mice and keyboards. But at least half of the idea is doable today, v00d00 free. All it takes is playing with the button events. An assumption must be made that the moment the cursor enters a button area the users intention is to click it and heavy processing can begin right away. The moment the user actually clicks the button it's a confirmation that he really wants the action to take place. If the cursor moves out of the button that's a cancel event and the operation is aborted (I can think about more complex strategies but that will do just fine for a PoC).</p>
<p>I mentioned that it was a lazy Sunday afternoon, right? So don't expect very much from the code, it was written in a moment of inspiration and is not fully functional (the cancellation event isn't implemented, so reuse the code at you're own risk). Just a PoC.</p>
<p>You can download the sources for the demonstration form. Feel the difference between the "Preemptive Button" and "Simple Button" where both have a Thread.Sleep(1000), but the user experience is different (also depends on how fast you handle your mouse).</p>
<p>To explain the idea, for the preemptive button the action is split between "heavy processing" and "result processing". The simple button does everything in a single action. The "heavy processing" is processed in the background when the PreemtiveEvents senses that the user might have the intention of clicking the button. Once the intention is confirmed, it will wait for the heavy processing to finish and then call the result processing passing it the output value from the previous action. Simple.</p>

	public partial class PreemptiveTestForm : Form
	{
		private DateTime start;
    
		public PreemptiveTestForm()
		{
			InitializeComponent();
			PreemptiveEvents preemptiveEvents = new PreemptiveEvents();
			preemptiveEvents.RegisterAction(btnPreemptive,
				() => { Thread.Sleep(1000); return 1; }, //heavy processing
				x => { MessageBox.Show("The output is "" + x); }); //result processing
		}
    
		private void btnSimple_Click(object sender, EventArgs e)
		{
			Thread.Sleep(1000);
			MessageBox.Show("The output is 2");
		}
	}

Long running processes will probably not benefit from this technique, but for processes with up to 2-3 sec execution time, the difference is obvious.

To make a stronger point on the Preemtive UI, let's continue on the photos idea. For example you are making a photo viewer program, and one of the most common actions are the rotate buttons (after the next of course). Rotation may take a second, even more depending on the image size and quality. How about implementing preemptive events for that? The user will get a fast result and will be happy that you're program is so much faster than the windows photo viewer (well actually any photo viewer is faster than the windows one..)

I didn't google for any similar techniques, I did it just for fun and I did enjoy doing it. Not sure if it's worth adding as a project to github, the solutions might be so different for different applications and I don't see a point of trying to make a general one.

Did your imagination go crazy? Leave a comment.
