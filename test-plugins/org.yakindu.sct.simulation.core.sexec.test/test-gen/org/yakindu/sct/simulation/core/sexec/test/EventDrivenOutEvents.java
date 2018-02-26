/* Generated by YAKINDU Statechart Tools code generator. */
package org.yakindu.sct.simulation.core.sexec.test;
import static org.junit.Assert.assertTrue;

import org.eclipse.xtext.junit4.InjectWith;
import org.eclipse.xtext.junit4.XtextRunner;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.yakindu.sct.model.sexec.ExecutionFlow;
import org.yakindu.sct.model.sexec.interpreter.test.util.AbstractExecutionFlowTest;
import org.yakindu.sct.model.sexec.interpreter.test.util.SExecInjectionProvider;
/**
 * Unit TestCase for EventDrivenOutEvents
 */
@SuppressWarnings("all")
@RunWith(XtextRunner.class)
@InjectWith(SExecInjectionProvider.class)
public class EventDrivenOutEvents extends AbstractExecutionFlowTest {
	@Before
	public void setup() throws Exception {
		ExecutionFlow flow = models.loadExecutionFlowFromResource("EventDrivenOutEvents.sct");
		initInterpreter(flow, true);
	}
	@Test
	public void test() throws Exception {
		interpreter.enter();
		assertTrue(isStateActive("StateA"));
		assertTrue(isStateActive("StateC"));
		raiseEvent("e1");
		assertTrue(isStateActive("StateB"));
		assertTrue(isStateActive("StateD"));
		interpreter.exit();
	}
}
