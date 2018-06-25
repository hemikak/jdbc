/*
 * Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 * WSO2 Inc. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 *
 */

package org.ballerinalang.nativeimpl.observe.tracing;

import org.ballerinalang.bre.Context;
import org.ballerinalang.bre.bvm.BlockingNativeCallableUnit;
import org.ballerinalang.model.types.TypeKind;
import org.ballerinalang.model.values.BInteger;
import org.ballerinalang.model.values.BMap;
import org.ballerinalang.natives.annotations.Argument;
import org.ballerinalang.natives.annotations.BallerinaFunction;
import org.ballerinalang.natives.annotations.ReturnType;

import static org.ballerinalang.nativeimpl.observe.tracing.OpenTracerBallerinaWrapper.ROOT_SPAN_INDICATOR;

/**
 * This function which implements the startSpan method for tracing.
 */
@BallerinaFunction(
        orgName = "ballerina",
        packageName = "observe",
        functionName = "startRootSpan",
        args = {
                @Argument(name = "serviceName", type = TypeKind.STRING),
                @Argument(name = "spanName", type = TypeKind.STRING),
                @Argument(name = "tags", type = TypeKind.MAP),
        },
        returnType = @ReturnType(type = TypeKind.INT),
        isPublic = true
)
public class StartRootSpan extends BlockingNativeCallableUnit {

    @Override
    public void execute(Context context) {

        String spanName = context.getStringArgument(0);
        BMap tags = (BMap) context.getNullableRefArgument(0);
        int spanId = OpenTracerBallerinaWrapper
                .getInstance().startSpan(spanName, Utils.toStringMap(tags), ROOT_SPAN_INDICATOR, context);

        context.setReturnValues(new BInteger(spanId));
    }
}
