/*
 * Copyright (c) 2017, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 * WSO2 Inc. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package org.ballerinalang.nativeimpl.io.channels.base;

import org.ballerinalang.nativeimpl.io.BallerinaIOException;
import org.ballerinalang.nativeimpl.io.channels.base.readers.Reader;
import org.ballerinalang.nativeimpl.io.channels.base.writers.Writer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.io.InputStream;
import java.nio.ByteBuffer;
import java.nio.channels.ByteChannel;
import java.nio.channels.Channels;
import java.nio.channels.WritableByteChannel;

/**
 * <p>
 * Represents the channel which allows reading/writing bytes to I/O devices.
 * </p>
 * <p>
 * Any channel implementation could inherit it's base methods from this.
 * </p>
 * <p>
 * <b>Note : </b> this channel does not support concurrent reading/writing, hence this should not be accessed
 * concurrently.
 * </p>
 *
 * @see Channel
 * @see CharacterChannel
 * @see DelimitedRecordChannel
 */
public abstract class AbstractChannel {

    /**
     * Will be used to read/write bytes to/from channels.
     */
    private ByteChannel channel;

    /**
     * Specifies how the content should be read from the channel.
     */
    private Reader reader;

    /**
     * Specifies how the content should be written to a channel.
     */
    private Writer writer;

    /**
     * Specifies whether the channel has reached EoF.
     */
    private boolean hasReachedToEnd = false;

    private static final Logger log = LoggerFactory.getLogger(AbstractChannel.class);

    /**
     * Creates a ballerina channel which will source/sink from I/O resource.
     *
     * @param channel the channel to source/sink bytes.
     */
    public AbstractChannel(ByteChannel channel, Reader reader, Writer writer) throws BallerinaIOException {
        if (null != channel) {
            this.channel = channel;
            this.reader = reader;
            this.writer = writer;
            if (log.isDebugEnabled()) {
                log.debug("Initializing ByteChannel with ref id " + channel.hashCode());
            }
        } else {
            String message = "The provided information is incorrect, the specified channel ";
            throw new BallerinaIOException(message);
        }
    }

    /**
     * Will be used when performing direct transfer operations from OS cache.
     *
     * @param position   starting position of the bytes to be transferred.
     * @param count      number of bytes to be transferred.
     * @param dstChannel destination channel to transfer.
     * @throws BallerinaIOException during I/O error.
     */
    public abstract void transfer(int position, int count, WritableByteChannel dstChannel) throws BallerinaIOException;

    /**
     * <p>
     * Async read bytes from the channel.
     * </p>
     *
     * @param buffer the buffer which will hold the content.
     * @return the number of bytes read.
     */
    public int read(ByteBuffer buffer) throws BallerinaIOException {
        int readBytes = reader.read(buffer, channel);
        if (readBytes <= 0) {
            hasReachedToEnd = true;
        }
        return readBytes;
    }

    /**
     * Specifies whether the channel has reached to it's end.
     *
     * @return true if the channel has reached to it's end
     */
    boolean hasReachedEnd() {
        return hasReachedToEnd;
    }

    /**
     * <p>
     * Writes provided buffer content to the channel.
     * </p>
     *
     * @param content the buffer which holds the content.
     * @return the number of bytes written to the channel.
     * @throws BallerinaIOException during I/O error.
     */
    int write(ByteBuffer content) throws BallerinaIOException {
        return writer.write(content, channel);
    }

    /**
     * Closes the given channel.
     */
    public void close() {
        try {
            if (null != channel) {
                channel.close();
            } else {
                log.error("The channel has already being closed.");
            }
        } catch (IOException e) {
            String message = "Error occurred while closing the connection. ";
            throw new BallerinaIOException(message, e);
        }
    }

    /**
     * This will return {@link InputStream} from underlying {@link ByteChannel}.
     *
     * @return An {@link InputStream}
     */
    public InputStream getInputStream() {
        if (!channel.isOpen()) {
            String message = "Channel is already closed.";
            throw new BallerinaIOException(message);
        }
        return Channels.newInputStream(channel);
    }
}
