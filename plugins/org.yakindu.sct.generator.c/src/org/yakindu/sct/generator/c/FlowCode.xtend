/**
 * Copyright (c) 2012 committers of YAKINDU and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * Contributors:
 * 	committers of YAKINDU - initial API and implementation
 * 
 */
package org.yakindu.sct.generator.c

import com.google.inject.Inject
import org.yakindu.sct.generator.c.extensions.GenmodelEntries
import org.yakindu.sct.generator.c.extensions.Naming
import org.yakindu.sct.model.sexec.Call
import org.yakindu.sct.model.sexec.Check
import org.yakindu.sct.model.sexec.CheckRef
import org.yakindu.sct.model.sexec.EnterState
import org.yakindu.sct.model.sexec.Execution
import org.yakindu.sct.model.sexec.ExitState
import org.yakindu.sct.model.sexec.HistoryEntry
import org.yakindu.sct.model.sexec.If
import org.yakindu.sct.model.sexec.SaveHistory
import org.yakindu.sct.model.sexec.ScheduleTimeEvent
import org.yakindu.sct.model.sexec.Sequence
import org.yakindu.sct.model.sexec.StateSwitch
import org.yakindu.sct.model.sexec.Step
import org.yakindu.sct.model.sexec.Trace
import org.yakindu.sct.model.sexec.TraceStateEntered
import org.yakindu.sct.model.sexec.TraceStateExited
import org.yakindu.sct.model.sexec.UnscheduleTimeEvent
import org.yakindu.sct.model.sexec.extensions.SExecExtensions
import org.yakindu.sct.model.sexec.naming.INamingService
import org.yakindu.sct.model.sgen.GeneratorEntry

class FlowCode {
	
	@Inject extension Naming
	@Inject extension SExecExtensions
	@Inject extension CExpressionsGenerator
	@Inject extension INamingService
	@Inject extension GenmodelEntries
 
 	@Inject GeneratorEntry entry
 
	def stepComment(Step it) '''
		«IF !comment.nullOrEmpty»
			/* «comment» */
		«ENDIF»
	'''
	
	def dispatch CharSequence code(Step it) '''
		#error ActionCode for Step '«getClass().name»' not defined
	'''
	
// ignore all trace steps not explicitly supported
	def dispatch CharSequence code(Trace it)''''''
	
	def dispatch CharSequence code(TraceStateEntered it) '''
		«IF entry.tracingEnterState»
		«flow.type.toFirstLower»_stateEntered(«scHandle», «it.state.stateName»);
		«ENDIF»
	'''
	
	def dispatch CharSequence code(TraceStateExited it) '''
		«IF entry.tracingExitState»
		«flow.type.toFirstLower»_stateExited(«scHandle», «it.state.stateName»);
		«ENDIF»
	'''

	def dispatch CharSequence code(SaveHistory it) '''
		«stepComment»
		«scHandle»->historyVector[«region.historyVector.offset»] = «scHandle»->stateConfVector[«region.stateVector.offset»];
	'''
	
	def dispatch CharSequence code(HistoryEntry it) '''
		«stepComment»
		if («scHandle»->historyVector[«region.historyVector.offset»] != «null_state»)
		{
			«historyStep.code»
		} «IF initialStep !== null»else
		{
			«initialStep.code»
		} «ENDIF»
	'''

	def dispatch CharSequence code(StateSwitch it) '''
		«stepComment»
		«IF historyRegion !== null»
			switch(«scHandle»->historyVector[ «historyRegion.historyVector.offset» ])
			{
		«ELSE»
			switch(«scHandle»->stateConfVector[ «stateConfigurationIdx» ])
			{
		«ENDIF»
			«FOR caseid : cases»
				case «caseid.state.stateName» :
				{
					«caseid.step.code»
					break;
				}
			«ENDFOR»
			default: break;
		}
	'''

	def dispatch CharSequence code(ScheduleTimeEvent it) '''
		«stepComment»
		«flow.type.toFirstLower»_setTimer(«scHandle», (sc_eventid) &(«scHandle»->timeEvents.«timeEvent.shortName»_raised) , «timeValue.code», «IF timeEvent.periodic»bool_true«ELSE»bool_false«ENDIF»);
	'''

	def dispatch CharSequence code(UnscheduleTimeEvent it) '''
		«stepComment»
		«flow.type.toFirstLower»_unsetTimer(«scHandle», (sc_eventid) &(«scHandle»->timeEvents.«timeEvent.shortName»_raised) );		
	'''

	def dispatch CharSequence code(Execution it)
		'''«statement.code»;'''
	
	def dispatch CharSequence code(Call it)
		'''«step.shortName»(«scHandle»);'''

	def dispatch CharSequence code(Sequence it) '''
		«IF !steps.nullOrEmpty»«stepComment»«ENDIF»
		«FOR s : steps»
			«s.code»
		«ENDFOR»
	'''	

	def dispatch CharSequence code(Check it)
		'''«IF condition !== null»«condition.sc_boolean_code»«ELSE»bool_true«ENDIF»'''
	
	def dispatch CharSequence code(CheckRef it)
		'''«IF check !== null»«check.shortName»(«scHandle»)«ELSE»bool_true«ENDIF»'''

	def dispatch CharSequence code(If it) '''
		«stepComment»
		if («check.code» == bool_true)
		{ 
			«thenStep.code»
		} «IF (elseStep !== null)» else
		{
			«elseStep.code»
		}
		«ENDIF»
	'''
	
	def dispatch CharSequence code(EnterState it) '''
		«scHandle»->stateConfVector[«state.stateVector.offset»] = «state.stateName»;
		«scHandle»->stateConfVectorPosition = «state.stateVector.offset»;
	'''

	def dispatch CharSequence code(ExitState it) '''
		«scHandle»->stateConfVector[«state.stateVector.offset»] = «null_state»;
		«scHandle»->stateConfVectorPosition = «state.stateVector.offset»;
	'''
}
